import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class SpriteBodyExample extends Forge2DGame {
  static const String description = '''
    In this example we show how to add a sprite on top of a `BodyComponent`.
    Tap the screen to add more pizzas.
  ''';

  SpriteBodyExample()
      : super(
          gravity: Vector2(0, 10.0),
          world: SpriteBodyWorld(),
        );
}

class SpriteBodyWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    addAll(createBoundaries(game));
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final position = info.localPosition;
    add(Pizza(position, size: Vector2(10, 15)));
  }
}

class Pizza extends BodyComponent {
  final Vector2 initialPosition;
  final Vector2 size;

  Pizza(
    this.initialPosition, {
    Vector2? size,
  }) : size = size ?? Vector2(2, 3);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await game.loadSprite('pizza.png');
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
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      position: initialPosition,
      angle: (initialPosition.x + initialPosition.y) / 2 * pi,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
