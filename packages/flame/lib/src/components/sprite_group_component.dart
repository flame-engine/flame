import 'dart:ui';

import 'package:meta/meta.dart';

import '../extensions/vector2.dart';
import '../sprite_animation.dart';
import 'mixins/has_paint.dart';
import 'position_component.dart';

export '../sprite_animation.dart';

/// A [PositionComponent] that can have mutiple [Sprite]s and render
/// the one mapped with the [current] key.
class SpriteGroupComponent<T> extends PositionComponent with HasPaint {
  /// Key with the current playing animation
  T? current;

  /// Map with the available states for this sprite group
  Map<T, Sprite>? sprites;

  /// Creates a component with an empty animation which can be set later
  SpriteGroupComponent({
    this.sprites,
    Vector2? position,
    Vector2? size,
    int? priority,
    this.current,
    Paint? paint,
  }) : super(
          position: position,
          size: size,
          priority: priority,
        ) {
    if (paint != null) {
      this.paint = paint;
    }
  }

  Sprite? get sprite => sprites?[current];

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.render(
      canvas,
      size: size,
      overridePaint: paint,
    );
  }
}
