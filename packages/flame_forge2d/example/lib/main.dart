import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: Forge2DExample.new));
}

class Forge2DExample extends Forge2DGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport.add(FpsTextComponent());
    world.add(Ball());
    world.addAll(createBoundaries());
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }
}

class Ball extends BodyComponent with TapCallbacks {
  Ball({Vector2? initialPosition})
    : super(
        fixtureDefs: [
          FixtureDef(
            CircleShape()..radius = 5,
            restitution: 0.8,
            friction: 0.4,
          ),
        ],
        bodyDef: BodyDef(
          angularDamping: 0.8,
          position: initialPosition ?? Vector2.zero(),
          type: BodyType.dynamic,
        ),
      );

  @override
  void onTapDown(_) {
    body.applyLinearImpulse(Vector2.random() * 5000);
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
