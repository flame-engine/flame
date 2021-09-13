import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

import 'boundaries.dart';

class Pizza extends SpriteBodyComponent {
  final Vector2 _position;

  Pizza(this._position, Image image) : super(Sprite(image), Vector2(10, 15));

  @override
  Body createBody() {
    final shape = PolygonShape();

    final vertices = [
      Vector2(-size.x / 2, -size.y / 2),
      Vector2(size.x / 2, -size.y / 2),
      Vector2(0, size.y / 2),
    ];
    shape.set(vertices);

    final fixtureDef = FixtureDef(shape)
      ..userData = this // To be able to determine object in collision
      ..restitution = 0.3
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = _position
      ..angle = (_position.x + _position.y) / 2 * 3.14
      ..type = BodyType.dynamic;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class SpriteBodySample extends Forge2DGame with TapDetector {
  late Image _pizzaImage;

  SpriteBodySample() : super(gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pizzaImage = await images.load('pizza.png');
    addAll(createBoundaries(this));
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final position = details.eventPosition.game;
    add(Pizza(position, _pizzaImage));
  }
}
