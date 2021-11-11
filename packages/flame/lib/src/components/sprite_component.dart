import 'dart:ui';

import 'package:meta/meta.dart';

import '../../components.dart';
import '../extensions/image.dart';
import '../extensions/vector2.dart';
import '../sprite.dart';
import 'component.dart';
import 'mixins/has_paint.dart';
import 'position_component.dart';

export '../sprite.dart';

/// A [PositionComponent] that renders a single [Sprite] at the designated
/// position, scaled to have the designated size and rotated to the specified
/// angle.
///
/// This a commonly used subclass of [Component].
class SpriteComponent extends PositionComponent with HasPaint {
  /// The [sprite] to be rendered by this component.
  Sprite? sprite;

  /// Creates a component with an empty sprite which can be set later
  SpriteComponent({
    this.sprite,
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          position: position,
          size: size ?? sprite?.srcSize,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  SpriteComponent.fromImage(
    Image image, {
    Vector2? srcPosition,
    Vector2? srcSize,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : this(
          sprite: Sprite(
            image,
            srcPosition: srcPosition,
            srcSize: srcSize,
          ),
          position: position,
          size: size ?? srcSize ?? image.size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    sprite?.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }
}
