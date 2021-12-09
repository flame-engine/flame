import 'dart:ui';

import 'package:flame/input.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:forge2d/forge2d.dart';

import 'boundaries.dart';
import 'sprite_body_sample.dart';

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
    add(Pizza(position));
  }
}
