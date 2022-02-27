import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum Shapes { circle, rectangle, polygon }

class SimpleShapesExample extends FlameGame with HasTappables {
  static const description = '''
    An example which adds random shapes on the screen when you tap it, if you
    tap on an already existing shape it will remove that shape and replace it
    with a new one.
  ''';

  final _rng = Random();

  PositionComponent randomShape(Vector2 position) {
    final shapeType = Shapes.values[_rng.nextInt(Shapes.values.length)];
    final shapeSize =
        Vector2.all(100) + Vector2.all(50.0).scaled(_rng.nextDouble());
    final shapeAngle = _rng.nextDouble() * 6;
    final hitbox = () {
      switch (shapeType) {
        case Shapes.circle:
          return HitboxCircle();
        case Shapes.rectangle:
          return HitboxRectangle();
        case Shapes.polygon:
          final points = [
            Vector2.random(_rng),
            Vector2.random(_rng)..y *= -1,
            -Vector2.random(_rng),
            Vector2.random(_rng)..x *= -1,
          ];

          return HitboxPolygon.fromNormals(points, size: shapeSize);
      }
    }();
    hitbox.paint.color = ColorExtension.random(withAlpha: 0.8, base: 100);
    hitbox.renderShape = true;
    return MyShapeComponent(
      position: position,
      size: shapeSize,
      angle: shapeAngle,
    )..add(hitbox);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    final tapPosition = info.eventPosition.game;
    final component = randomShape(tapPosition);
    add(component);
    component
      ..add(
        MoveEffect.to(
          size / 2,
          EffectController(
            duration: 5,
            reverseDuration: 5,
            infinite: true,
          ),
        ),
      )
      ..add(
        RotateEffect.to(
          3,
          EffectController(
            duration: 1,
            reverseDuration: 1,
            infinite: true,
          ),
        ),
      );
  }
}

class MyShapeComponent extends PositionComponent with Tappable {
  MyShapeComponent({
    Vector2? position,
    Vector2? size,
    double? angle,
  }) : super(
          position: position,
          size: size,
          angle: angle,
          anchor: Anchor.center,
        );

  @override
  bool onTapDown(TapDownInfo _) {
    removeFromParent();
    return true;
  }
}
