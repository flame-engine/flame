import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:flame/src/sprite_warp/sprite_warp_renderer.dart';
import 'package:meta/meta.dart';

/// A mixin for components that can warp (distort) their sprite with a
/// [WarpGrid], similarly to SpriteKit's `SKWarpGeometryGrid`.
///
/// It works with any component that renders its sprite through
/// [RendersSprite], like [SpriteComponent], [SpriteGroupComponent],
/// [SpriteAnimationComponent] and [SpriteAnimationGroupComponent].
///
/// ```dart
/// class WarpedSprite extends SpriteComponent with HasWarpGrid {
///   WarpedSprite({super.sprite, super.size}) {
///     warpGrid = WarpGrid.identity(columns: 2, rows: 2);
///   }
/// }
/// ```
///
/// While [warpGrid] is `null` the sprite is rendered as usual. Warping only
/// changes how the sprite is drawn: the component's size, hit testing and
/// collisions are not affected.
mixin HasWarpGrid on RendersSprite, ImageRetainer implements WarpGridProvider {
  /// The grid used to warp the sprite, or `null` to render it undistorted.
  ///
  /// The grid's destination positions are relative to the component's
  /// [size]. Since [WarpGrid] is immutable, assign a new grid to change the
  /// warp, or animate it with a `WarpEffect`.
  @override
  WarpGrid? warpGrid;

  /// How [warpGrid] is interpolated between its vertices.
  WarpInterpolation warpInterpolation = WarpInterpolation.bilinear;

  SpriteWarpRenderer? _warpRenderer;

  /// The renderer used while [warpGrid] is set.
  @visibleForTesting
  SpriteWarpRenderer? get warpRenderer => _warpRenderer;

  @override
  void updateRetainedImages() {
    // The warp renderer holds an image shader, which would keep the previous
    // image alive after it is released (and possibly evicted).
    _disposeWarpRenderer();
    super.updateRetainedImages();
  }

  @override
  @mustCallSuper
  void onRemove() {
    _disposeWarpRenderer();
    super.onRemove();
  }

  @override
  void renderSprite(Canvas canvas, Sprite sprite) {
    final warpGrid = this.warpGrid;
    if (warpGrid == null) {
      _disposeWarpRenderer();
      super.renderSprite(canvas, sprite);
      return;
    }
    (_warpRenderer ??= SpriteWarpRenderer()).render(
      canvas,
      sprite: sprite,
      grid: warpGrid,
      interpolation: warpInterpolation,
      width: size.x,
      height: size.y,
      paint: paint,
      bleed: bleed ?? 0,
    );
  }

  void _disposeWarpRenderer() {
    _warpRenderer?.dispose();
    _warpRenderer = null;
  }
}
