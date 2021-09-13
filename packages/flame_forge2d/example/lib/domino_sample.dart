import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/sprite_body_component.dart';
import 'package:forge2d/forge2d.dart';

import 'boundaries.dart';

class Pizza extends SpriteBodyComponent {
  final Vector2 position;

  Pizza(this.position, Image image) : super(Sprite(image), Vector2(2, 3));

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
      ..restitution = 0.4
      ..density = 1.0
      ..friction = 0.5;

    final bodyDef = BodyDef()
      ..position = position
      ..angle = (position.x + position.y) / 2 * 3.14
      ..type = BodyType.dynamic;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Platform extends BodyComponent {
  final Vector2 position;

  Platform(this.position);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(14.8, 0.125);
    final fixtureDef = FixtureDef(shape);

    final bodyDef = BodyDef();
    bodyDef.position = position;
    final body = world.createBody(bodyDef);
    return body..createFixture(fixtureDef);
  }
}

class DominoBrick extends BodyComponent {
  final Vector2 position;

  DominoBrick(this.position);

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(0.125, 2.0);
    final fixtureDef = FixtureDef(shape)
      ..density = 25.0
      ..restitution = 0.4
      ..friction = 0.5;

    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class DominoSample extends Forge2DGame with TapDetector {
  late Image pizzaImage;

  DominoSample() : super(gravity: Vector2(0, -10.0));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    pizzaImage = await images.load('pizza.png');
    final center = screenToWorld(camera.viewport.effectiveSize / 2);

    for (var i = 0; i < 8; i++) {
      final position = center + Vector2(0.0, -30.0 + 5 * i);
      add(Platform(position));
    }

    const numberOfRows = 10;
    const numberPerRow = 25;
    for (var i = 0; i < numberOfRows; ++i) {
      for (var j = 0; j < numberPerRow; j++) {
        final position = center +
            Vector2(-14.75 + j * (29.5 / (numberPerRow - 1)), -27.7 + 5 * i);
        add(DominoBrick(position));
      }
    }
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final position = details.eventPosition.game;
    final pizza = Pizza(position, pizzaImage);
    add(pizza);
  }
}
