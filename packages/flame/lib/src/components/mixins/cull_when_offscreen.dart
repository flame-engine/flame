import 'dart:math';
import 'dart:ui';

import 'package:flame/src/camera/camera_component.dart';
import 'package:flame/src/camera/world.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/mixins/has_visibility.dart';
import 'package:flame/src/components/position_component.dart';
import 'package:meta/meta.dart';

/// Skips drawing a [PositionComponent] while it is off-screen.
///
/// When the component is outside of what the camera shows, its `render` is not
/// called, and neither is the `render` of its children. This saves time in
/// games with many components. Only drawing is skipped: `update`, collisions
/// and effects keep working.
///
/// ## The main rule
///
/// **Everything the component draws, including its children, must fit inside
/// its [cullBounds] plus [cullPadding].**
///
/// The decision only looks at the component itself. If a child sticks out of
/// the parent's box, it disappears as soon as the parent's box leaves the
/// screen, even if the child is still visible. Nothing warns you about this,
/// unless you turn on [debugVerifyCulledSubtrees].
///
/// ## Good to know
///
/// - Only components inside a [World] are culled. Components in the viewport
///   (like a HUD) are never culled.
/// - Each camera decides for itself. A minimap and the main camera can see
///   different things.
/// - Using the mixin on both a parent and its children is fine. A culled
///   parent skips its children, and a visible parent lets each child decide.
/// - A custom `Decorator` that moves the drawing is not taken into account.
///   Override [cullBounds] in that case.
/// - A culled component does not call `render`, so do not keep per-frame work
///   in `render`. Use `update` instead.
///
/// ## Choosing [cullPadding]
///
/// Use the farthest distance, in world units, that anything reaches outside of
/// the box. For example: a shadow's offset plus its blur, half of an outline's
/// width, or how far a child sticks out. When unsure, use a bigger number. It
/// only costs a few extra components drawn near the edge of the screen.
///
/// Prefer using this mixin on many small components, like sprites and tiles.
/// For scenery that never changes, use a `SpriteBatchComponent` instead.
mixin CullWhenOffscreen on PositionComponent {
  /// Turns culling on or off for this component only.
  ///
  /// When false, this component is always drawn, as long as its parent is
  /// drawn. If the parent is culled, the parent skips its children, so this
  /// component is skipped too.
  bool cullingEnabled = true;

  /// Turns on an extra check that helps to find culling mistakes. Use it only
  /// while developing, because it is slow.
  ///
  /// When a component is about to be culled, this looks at all of its children.
  /// If one of them is on-screen, an [AssertionError] is thrown. The message
  /// tells you which [cullPadding] fixes the problem.
  ///
  /// This is off by default, and it does nothing in release builds.
  ///
  /// ```dart
  /// void main() {
  ///   CullWhenOffscreen.debugVerifyCulledSubtrees = true;
  ///   runApp(GameWidget(game: MyGame()));
  /// }
  /// ```
  ///
  /// It only checks children that are [PositionComponent]s. It cannot see what
  /// a component draws by itself in `render` outside of its [size], like a
  /// shadow. Use [cullPadding] for that.
  static bool debugVerifyCulledSubtrees = false;

  /// Extra space, in world units, added around [cullBounds] before checking if
  /// the component is on-screen.
  ///
  /// Use it when the component or its children draw outside of the [size] box.
  double cullPadding = 0;

  /// The area of the world that this component takes up.
  ///
  /// By default this is the box made by the position, size, anchor, scale and
  /// angle of the component and its parents. Override it when the [size] is not
  /// what the component really draws, for example when the size is zero.
  Rect get cullBounds {
    // Fast path for the common case of a direct child of the world that is not
    // rotated, which avoids the vector allocations of `toAbsoluteRect`.
    if (angle == 0 && parent is World) {
      final width = size.x * scale.x;
      final height = size.y * scale.y;
      final left = position.x - anchor.x * width;
      final top = position.y - anchor.y * height;
      return Rect.fromLTRB(
        min(left, left + width),
        min(top, top + height),
        max(left, left + width),
        max(top, top + height),
      );
    }
    return toAbsoluteRect();
  }

  World? _world;

  @mustCallSuper
  @override
  void onMount() {
    super.onMount();
    _world = findParent<World>();
  }

  @mustCallSuper
  @override
  void onRemove() {
    _world = null;
    super.onRemove();
  }

  @override
  void renderTree(Canvas canvas) {
    if (_isOffscreen()) {
      return;
    }
    super.renderTree(canvas);
  }

  bool _isOffscreen() {
    final world = _world;
    if (!cullingEnabled ||
        world == null ||
        CameraComponent.currentCameras.isEmpty) {
      return false;
    }
    // The innermost camera is the one currently rendering this component.
    final camera = CameraComponent.currentCameras.last;
    if (camera.world != world) {
      return false;
    }
    final bounds = cullBounds;
    final visibleRect = camera.visibleWorldRect;
    final offscreen = !visibleRect.overlaps(
      cullPadding == 0 ? bounds : bounds.inflate(cullPadding),
    );
    assert(_debugVerifyCulledSubtree(offscreen, visibleRect, bounds));
    return offscreen;
  }

  /// Only used in an assert, see [debugVerifyCulledSubtrees]. Always returns
  /// true, or throws when a culled component has a visible descendant.
  bool _debugVerifyCulledSubtree(
    bool offscreen,
    Rect visibleRect,
    Rect bounds,
  ) {
    if (offscreen && debugVerifyCulledSubtrees && hasChildren) {
      final problem = _debugCulledSubtreeProblem(visibleRect, bounds);
      if (problem != null) {
        throw AssertionError(problem);
      }
    }
    return true;
  }

  /// Returns a description of the problem when this component is culled while
  /// one of its descendants is visible, and null when culling is correct.
  String? _debugCulledSubtreeProblem(Rect visibleRect, Rect bounds) {
    PositionComponent? visibleDescendant;
    var requiredPadding = 0.0;
    // A hidden `HasVisibility` component hides all of its descendants too, so
    // its whole subtree is skipped.
    final pending = <Component>[this];
    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (!current.hasChildren) {
        continue;
      }
      for (final child in current.children) {
        if (child is HasVisibility && !child.isVisible) {
          continue;
        }
        pending.add(child);
        if (child is! PositionComponent) {
          continue;
        }
        final rect = child.toAbsoluteRect();
        requiredPadding = max(
          requiredPadding,
          max(
            max(bounds.left - rect.left, rect.right - bounds.right),
            max(bounds.top - rect.top, rect.bottom - bounds.bottom),
          ),
        );
        if (visibleDescendant == null && visibleRect.overlaps(rect)) {
          visibleDescendant = child;
        }
      }
    }
    if (visibleDescendant == null) {
      return null;
    }
    return '$runtimeType is off-screen and was skipped, but its child '
        '${visibleDescendant.runtimeType} is on-screen. A skipped component '
        'also skips its children. Set cullPadding to at least '
        '${requiredPadding.ceil()} (it is now $cullPadding), or override '
        'cullBounds.';
  }
}
