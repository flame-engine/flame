import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/rendering.dart';
import 'package:flame/src/collisions/hitboxes/shape_hitbox.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/has_decorator.dart';
import 'package:flame/src/components/mixins/has_paint.dart';
import 'package:flame/src/components/mixins/snapshot.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/components/sprite_animation_component.dart';
import 'package:flame/src/components/sprite_component.dart';
import 'package:flame/src/sprite_batch.dart';
import 'package:meta/meta.dart';

/// A mixin that enables children of a [Component] to be automatically batched
/// into a single [Canvas.drawAtlas] call per shared atlas image per priority
/// group.
///
/// Eligible children must be [SpriteComponent] or [SpriteAnimationComponent]
/// instances with uniform scale and no extra decorators or snapshot caching.
/// They may either be leaf nodes or have only [ShapeHitbox] children, which
/// are ignored for batching. All other children fall back to their individual
/// [Component.renderTree] calls, and render order (z-order by priority) is
/// fully preserved.
///
/// Usage:
/// ```dart
/// class EnemyGroup extends PositionComponent with HasAutoBatchedChildren {}
/// ```
///
/// Toggle batching at runtime:
/// ```dart
/// final group = EnemyGroup();
/// group.batchingEnabled = false; // falls back to individual rendering
/// ```
mixin HasAutoBatchedChildren on Component {
  /// When `false`, every child is rendered individually (no batching).
  bool batchingEnabled = true;

  // Accumulators keyed by atlas identity hash.
  final Map<Image, _BatchAccumulator> _accumulators = {};

  // The priority of the child group currently being accumulated.
  int? _currentPriority;

  /// Renders [child] with batching if eligible, or falls back to individual
  /// rendering if not.
  ///
  /// Batching is performed at priority-group boundaries to preserve render
  /// order between eligible and non-eligible children. If a child is eligible
  /// for batching, its render info is extracted and accumulated into a batch
  /// for its atlas image. If not eligible, any pending batches are flushed
  /// before rendering the child individually, so that the child renders after
  /// any already-accumulated sprites (same priority group).
  @override
  @protected
  void renderChild(Canvas canvas, Component child) {
    if (!batchingEnabled) {
      super.renderChild(canvas, child);
      return;
    }

    // Detect priority-group boundary — flush before crossing it.
    final childPriority = child.priority;
    if (_currentPriority != null && childPriority != _currentPriority) {
      _flushAll(canvas);
    }
    _currentPriority = childPriority;

    final batchInfo = _tryGetBatchInfo(child);
    if (batchInfo != null) {
      _accumulateChild(child as PositionComponent, batchInfo);
      if (child.debugMode) {
        for (final hitbox in child.children.whereType<ShapeHitbox>()) {
          canvas.save();
          canvas.transform2D(child.transform);
          hitbox.renderDebugMode(canvas);
          canvas.restore();
        }
      }
    } else {
      // Non-eligible child: flush any pending batch first so that the child
      // renders after already-accumulated sprites (same priority group).
      _flushAll(canvas);
      super.renderChild(canvas, child);
    }
  }

  /// Flushes any pending batches after all children are rendered, so they
  /// render after all non-eligible children (same priority group) as well.
  ///
  /// This is necessary to ensure that batches render in the correct order
  /// relative to non-eligible children, but can be overridden if the flush
  /// needs to happen at a different time (e.g. before rendering a specific
  /// child) without breaking batching for the rest of the group.
  @override
  @protected
  void afterChildrenRendered(Canvas canvas) {
    _flushAll(canvas);
    _currentPriority = null;
    super.afterChildrenRendered(canvas);
  }

  /// Accumulates [child] for batching based on [info].
  void _accumulateChild(PositionComponent child, _BatchInfo info) {
    final accumulator = _accumulators[info.image] ??= _BatchAccumulator(
      info.image,
    );
    accumulator.accumulate(
      info.sourceRect,
      _toRSTransform(child, info.sourceRect),
      info.color,
    );
  }

  /// Flushes all accumulators to [canvas] and resets them for the next frame.
  ///
  /// This is called automatically at priority-group boundaries and after all
  /// children are rendered, but can also be called manually if needed (e.g. to
  /// flush before rendering a non-eligible child without breaking batching for
  /// the rest of the group).
  void _flushAll(Canvas canvas) {
    for (final acc in _accumulators.values) {
      acc.flush(canvas);
    }
    // Do NOT clear the map — reuse accumulators with the same images
    // across frames. Individual batch.clear() is called inside flush().
  }

  /// Returns the source [Image], [Rect], and tint [Color] for [component] if
  /// it is eligible for batching, or `null` if it should fall back to
  /// individual rendering.
  ///
  /// Combines type, state, and transform eligibility checks with source
  /// extraction so the call site never needs to call both separately.
  static _BatchInfo? _tryGetBatchInfo(Component component) {
    if (!component.isMounted) {
      return null;
    }

    // Decorators other than the built-in Transform2DDecorator are unsupported.
    if (component is HasDecorator && component.decorator != null) {
      return null;
    }

    if (component is! SpriteComponent &&
        component is! SpriteAnimationComponent) {
      return null;
    }

    final positionComponent = component as PositionComponent;
    final decorator = positionComponent.decorator;

    if (decorator is! Transform2DDecorator || !decorator.isLastDecorator) {
      return null;
    }

    // Allow children that produce no visible output in non-debug mode
    // (e.g. physics hitboxes) — they can be safely skipped during batching.
    if (positionComponent.children.any((child) => child is! ShapeHitbox)) {
      return null;
    }

    // Snapshot caching bypasses normal render — exclude it.
    if (positionComponent is Snapshot && positionComponent.renderSnapshot) {
      return null;
    }

    // Non-uniform scale cannot be expressed as a single RSTransform.
    if (positionComponent.scale.x != positionComponent.scale.y) {
      return null;
    }

    // Complex paint effects can't be expressed per-item; only simple alpha/
    // color tints (via HasPaint.paint.color) are supported.
    final hasPaint = component as HasPaint;
    final paint = hasPaint.paint;

    if (paint.colorFilter != null ||
        paint.shader != null ||
        paint.imageFilter != null ||
        paint.maskFilter != null ||
        // SpriteBatch's render() always uses BlendMode.srcOver, so any other
        // blend mode would be ignored and could lead to unexpected results.
        // We could support batching by blend mode (e.g., using a tuple as the
        // batch key (Image, BlendMode)), but that would be a more complex
        // change. For now, it's safer to just exclude non-srcOver blend modes.
        paint.blendMode != BlendMode.srcOver) {
      return null;
    }

    if (hasPaint.paintLayers.length > 1) {
      return null;
    }

    // Extract source info — null means the sprite/animation isn't ready yet.
    final (Image, Rect)? sourceInfo;

    if (component is SpriteComponent) {
      final sprite = component.sprite;

      if (sprite == null) {
        return null;
      }

      sourceInfo = (sprite.image, sprite.src);
    } else {
      final ticker = (component as SpriteAnimationComponent).animationTicker;

      if (ticker == null) {
        return null;
      }

      final frame = ticker.currentFrame;
      sourceInfo = (frame.sprite.image, frame.sprite.src);
    }

    // RSTransform encodes a 2D transform as a single rotation + uniform scale,
    // meaning scaleX and scaleY must be identical. When rendering a sprite,
    // the implied scale factors are:
    //   scaleX = size.x / sourceWidth
    //   scaleY = size.y / sourceHeight
    // For these to be equal: size.x / sourceWidth == size.y / sourceHeight
    //                  i.e.: size.x * sourceHeight == size.y * sourceWidth
    // We use cross-multiplication (instead of division) to avoid a sourceWidth/sourceHeight
    // zero-guard, and keep the tolerance (0.5) in absolute pixel-area units
    // so it stays stable regardless of sprite dimensions.
    final sourceWidth = sourceInfo.$2.width;
    final sourceHeight = sourceInfo.$2.height;
    if (sourceWidth <= 0 ||
        sourceHeight <= 0 ||
        (positionComponent.size.x * sourceHeight -
                    positionComponent.size.y * sourceWidth)
                .abs() >
            0.5) {
      return null;
    }

    // Convert fully-opaque white to transparent black (SpriteBatch's "no tint"
    // sentinel) — white is the multiplicative identity so it must stay neutral.
    final rawColor = hasPaint.paint.color;
    final batchColor = rawColor != const Color(0xFFFFFFFF)
        ? rawColor
        : const Color(0x00000000);

    return _BatchInfo(sourceInfo.$1, sourceInfo.$2, batchColor);
  }

  /// Builds an [RSTransform] for [component] in parent-local coordinate space.
  ///
  /// The effective scale is `c.scale.x × (c.size.x / src.width)` — the
  /// component's own scale combined with the source-to-size stretch factor.
  /// The anchor is expressed in source-rect coordinates so that
  /// [PositionComponent.position] maps to where [PositionComponent.anchor]
  /// lands in parent space.
  static RSTransform _toRSTransform(PositionComponent component, Rect source) {
    // Effective (uniform) scale = component scale × size-to-source stretch.
    final effectiveScale = component.scale.x * component.size.x / source.width;
    final totalAngle = component.angle + component.nativeAngle;
    final cosA = math.cos(totalAngle) * effectiveScale;
    final sinA = math.sin(totalAngle) * effectiveScale;

    // Anchor expressed in source-rect coordinates.
    final anchorX = component.anchor.x * source.width;
    final anchorY = component.anchor.y * source.height;

    // position is where the anchor maps to in parent space.
    return RSTransform(
      cosA,
      sinA,
      component.position.x - cosA * anchorX + sinA * anchorY,
      component.position.y - sinA * anchorX - cosA * anchorY,
    );
  }
}

/// Internal accumulator that wraps a [SpriteBatch] for a single atlas [Image].
///
/// Reused frame-to-frame: cleared and re-populated on each render pass via
/// [flush].
class _BatchAccumulator {
  _BatchAccumulator(Image atlas) : batch = SpriteBatch(atlas);

  final SpriteBatch batch;

  void accumulate(Rect source, RSTransform transform, Color color) {
    batch.addTransform(source: source, transform: transform, color: color);
  }

  /// Flushes all accumulated items to [canvas] and resets for next frame.
  void flush(Canvas canvas) {
    if (!batch.isEmpty) {
      // Always supply an explicit blendMode so that per-item colors never
      // trigger the bare-String throw inside SpriteBatch.render().
      batch.render(canvas, blendMode: BlendMode.srcOver);
      batch.clear();
    }
  }
}

/// Internal struct for batching info extracted from a component.
class _BatchInfo {
  _BatchInfo(this.image, this.sourceRect, this.color);

  final Image image;
  final Rect sourceRect;
  final Color color;
}
