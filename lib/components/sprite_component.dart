import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../extensions/vector2.dart';
import '../sprite.dart';
import 'component.dart';
import 'position_component.dart';

/// A [PositionComponent] that renders a single [Sprite] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This a commonly used subclass of [Component].
class SpriteComponent extends PositionComponent {
  /// The [sprite] to be rendered by this component.
  Sprite sprite;

  /// Use this to override the colour used (to apply tint or opacity).
  ///
  /// If not provided the default is full white (no tint).
  Paint overridePaint;

  SpriteComponent();

  SpriteComponent.fromImage(Vector2 size, Image image)
      : this.fromSprite(size, Sprite(image));

  SpriteComponent.fromSprite(Vector2 size, this.sprite) {
    super.size.setFrom(size);
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite.render(
      canvas,
      size: size,
      overridePaint: overridePaint,
    );
  }
}
