import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

/// A mixin for components that render a single [Sprite] at a time, filling
/// their [size], like [SpriteComponent], [SpriteGroupComponent],
/// [SpriteAnimationComponent] and [SpriteAnimationGroupComponent].
///
/// The sprite is drawn through [renderSprite], which mixins like
/// [HasWarpGrid] override to change how it is drawn.
mixin RendersSprite on PositionComponent, HasPaint {
  /// How many pixels the sprite is expanded by on every side when rendered.
  double? get bleed => null;

  /// Renders [sprite] onto the [canvas], in the local coordinates of the
  /// component.
  @protected
  void renderSprite(Canvas canvas, Sprite sprite) {
    sprite.render(
      canvas,
      size: size,
      overridePaint: paint,
      bleed: bleed,
    );
  }
}
