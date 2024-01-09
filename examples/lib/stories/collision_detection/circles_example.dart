import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image, Draggable;

class CirclesExample extends FlameGame {
  static const description = '''
    This example will create a circle every time you tap on the screen. It will
    have the initial velocity towards the center of the screen and if it touches
    another circle both of them will change color.
  ''';

  CirclesExample()
      : super(
          camera: CameraComponent.withFixedResolution(width: 600, height: 400),
          world: MyWorld(),
        );
}

class MyWorld extends World with TapCallbacks, HasCollisionDetection {
  MyWorld() : super(children: [ScreenHitbox()..debugMode = true]);

  @override
  void onTapDown(TapDownEvent info) {
    add(MyCollidable(position: info.localPosition));
  }
}

class MyCollidable extends PositionComponent
    with HasGameReference<CirclesExample>, CollisionCallbacks {
  MyCollidable({super.position})
      : super(size: Vector2.all(30), anchor: Anchor.center);

  late Vector2 velocity;
  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  late ShapeHitbox hitbox;

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox = CircleHitbox()
      ..paint = defaultPaint
      ..renderShape = true;
    add(hitbox);
    velocity = -position
      ..scaleTo(50);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.paint.color = _collisionColor;
    if (other is ScreenHitbox) {
      removeFromParent();
      return;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (!isColliding) {
      hitbox.paint.color = _defaultColor;
    }
  }
}
