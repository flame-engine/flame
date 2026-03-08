import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:meta/meta.dart';

/// A component that renders multiple instances of a synchronized animation
/// using a single [SpriteBatch] for maximum efficiency.
///
/// This component follows the Synchronized State Architecture, where
/// position and state updates are handled in batches, bypassing the standard
/// component lifecycle for child entities to maximize performance.
class UnifiedAnimationParentComponent extends Component {
  UnifiedAnimationParentComponent({
    required this.spriteBatch,
    required this.ticker,
    this.blendMode = BlendMode.srcOver,
    this.depthSort = false,
    this.culling = false,
    ColorFilter? colorFilter,
  }) : _paint = Paint()..colorFilter = colorFilter;

  /// The [SpriteBatch] used to render all instances.
  final SpriteBatch spriteBatch;

  /// The shared [SpriteAnimationTicker] that all instances follow.
  final SpriteAnimationTicker ticker;

  /// The [BlendMode] used when rendering the batch.
  final BlendMode blendMode;

  /// Whether to sort instances by their Y-coordinate before rendering.
  ///
  /// When enabled, instances with a larger Y-coordinate (lower on the screen)
  /// will be rendered "in front" of those with a smaller Y-coordinate.
  final bool depthSort;

  /// Whether to cull instances that are outside of the viewport.
  ///
  /// This requires the component to be part of a [FlameGame] to access the
  /// camera's visible world rectangle.
  final bool culling;

  final Paint _paint;

  /// The [ColorFilter] used when rendering the batch.
  ColorFilter? get colorFilter => _paint.colorFilter;
  set colorFilter(ColorFilter? value) => _paint.colorFilter = value;

  final List<Vector2> positions = [];
  final List<Vector2> sizes = [];
  final List<Color?> colors = [];

  /// Optional list of velocities. If null, the component assumes all instances
  /// are static and skips the movement update loop for better performance.
  List<Vector2?>? velocities;

  // Persistent index list to minimize allocations during sorting.
  // Initialized only if [depthSort] is enabled.
  @visibleForTesting
  List<int>? indices;

  /// Adds a new instance to be rendered by this component.
  void addInstance({
    required Vector2 position,
    required Vector2 size,
    Color? color,
    Vector2? velocity,
  }) {
    if (depthSort) {
      indices ??= List.generate(positions.length, (i) => i, growable: true);
      indices!.add(positions.length);
    }
    positions.add(position);
    sizes.add(size);
    colors.add(color);

    if (velocity != null && !velocity.isZero()) {
      velocities ??= List.filled(positions.length - 1, null, growable: true);
      velocities!.add(velocity);
    } else {
      velocities?.add(null);
    }
  }

  int? _lastFrameIndex;
  Rect _lastVisibleRect = Rect.zero;

  @override
  void update(double dt) {
    super.update(dt);
    final velocities = this.velocities;
    if (velocities != null) {
      for (var i = 0; i < positions.length; i++) {
        final v = velocities[i];
        if (v != null) {
          positions[i].addScaled(v, dt);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (positions.isEmpty) {
      return;
    }

    final sprite = ticker.getSprite();

    // Optimization: Only rebuild the batch if the animation frame changed
    // OR if depth sorting/culling is enabled AND entities are moving
    // OR if culling is enabled and camera moved.
    final isMoving = velocities?.any((v) => v != null) ?? false;
    var cameraMoved = false;
    Rect? visibleRect;
    if (culling) {
      final game = findGame();
      if (game != null) {
        visibleRect = game.camera.visibleWorldRect;
        cameraMoved = visibleRect != _lastVisibleRect;
      }
    }

    if ((depthSort && isMoving) ||
        (culling && (isMoving || cameraMoved)) ||
        ticker.currentIndex != _lastFrameIndex) {
      _lastFrameIndex = ticker.currentIndex;
      if (visibleRect != null) {
        _lastVisibleRect = visibleRect;
      }
      _rebuildBatch(sprite.src, visibleRect);
    }

    spriteBatch.render(
      canvas,
      blendMode: blendMode,
      paint: _paint,
    );
  }

  void _rebuildBatch(Rect source, [Rect? visibleRect]) {
    spriteBatch.clear();

    final indices = this.indices;
    if (depthSort && indices != null) {
      indices.sort((a, b) => positions[a].y.compareTo(positions[b].y));
    }

    for (var i = 0; i < positions.length; i++) {
      final index = (depthSort && indices != null) ? indices[i] : i;
      final position = positions[index];
      final size = sizes[index];

      if (visibleRect != null) {
        if (position.x + size.x < visibleRect.left ||
            position.x > visibleRect.right ||
            position.y + size.y < visibleRect.top ||
            position.y > visibleRect.bottom) {
          continue;
        }
      }

      spriteBatch.add(
        source: source,
        offset: position,
        scale: size.x / source.width,
        color: colors[index],
      );
    }
  }
}
