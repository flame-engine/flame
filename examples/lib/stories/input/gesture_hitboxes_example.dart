import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum Shapes { circle, rectangle, polygon }

class GestureHitboxesExample extends FlameGame
    with HasTappables, HasHoverables {
  static const description = '''
    Tap to create a PositionComponent with a randomly shaped hitbox.
    You can then hover over to shapes to see that they receive the hover events
    only when the cursor is within the shape. If you tap/click within the shape
    it is removed.
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
            -Vector2.random(_rng),
            Vector2.random(_rng)..x *= -1,
            Vector2.random(_rng),
            Vector2.random(_rng)..y *= -1,
          ];
          return HitboxPolygon.fromNormals(points, parentSize: shapeSize);
      }
    }();
    return MyShapeComponent(
      hitbox: hitbox,
      position: position,
      size: shapeSize,
      angle: shapeAngle,
    );
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    super.onTapDown(pointerId, info);
    final tapPosition = info.eventPosition.game;
    final component = randomShape(tapPosition);
    add(component);
  }
}

class MyShapeComponent extends PositionComponent
    with Tappable, Hoverable, GestureHitboxes {
  final HitboxShape hitbox;
  late final Color baseColor;
  late final Color hoverColor;

  MyShapeComponent({
    required this.hitbox,
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
  Future<void> onLoad() async {
    super.onLoad();
    baseColor = ColorExtension.random(withAlpha: 0.8, base: 100);
    hitbox.paint.color = baseColor;
    hitbox.renderShape = true;
    add(hitbox);
  }

  @override
  bool onTapDown(TapDownInfo _) {
    removeFromParent();
    return true;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    hitbox.paint.color = hitbox.paint.color.darken(0.5);
    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    hitbox.paint.color = baseColor;
    return true;
  }
}
