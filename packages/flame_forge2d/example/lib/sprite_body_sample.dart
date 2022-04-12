import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'boundaries.dart';

class SpriteBodySample extends Forge2DGame with TapDetector {
  SpriteBodySample() : super(gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    addAll(createBoundaries(this));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final position = details.eventPosition.game;
    add(Pizza(position, size: Vector2(10, 15)));
  }
}

class Pizza extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  Pizza(
    this.position, {
    Vector2? size,
  }) : size = size ?? Vector2(2, 3);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await gameRef.loadSprite('pizza.png');
    renderBody = false;
    add(
      SpriteComponent(
        sprite: sprite,
        size: size,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  Body createBody() {
    final shape = PolygonShape();

    final vertices = [
      Vector2(-size.x / 2, size.y / 2),
      Vector2(size.x / 2, size.y / 2),
      Vector2(0, -size.y / 2),
    ];
    shape.set(vertices);

    final fixtureDef = FixtureDef(
      shape,
      userData: this, // To be able to determine object in collision
      restitution: 0.4,
      density: 1.0,
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      position: position,
      angle: (position.x + position.y) / 2 * pi,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
