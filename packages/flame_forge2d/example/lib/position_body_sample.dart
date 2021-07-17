import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flame_forge2d/position_body_component.dart';
import 'package:forge2d/forge2d.dart';

import 'boundaries.dart';

class ChopperBody extends PositionBodyComponent {
  final Vector2 position;

  ChopperBody(
    this.position,
    PositionComponent component,
  ) : super(component, component.size);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 4;
    final fixtureDef = FixtureDef(shape)
      ..userData = this // To be able to determine object in collision
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final velocity = (Vector2.random() - Vector2.random()) * 200;
    final bodyDef = BodyDef()
      ..position = position
      ..angle = velocity.angleTo(Vector2(1, 0))
      ..linearVelocity = velocity
      ..type = BodyType.dynamic;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class PositionBodySample extends Forge2DGame with TapDetector {
  late Image chopper;
  late SpriteAnimation animation;

  PositionBodySample() : super(gravity: Vector2.zero());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    chopper = await images.load('chopper.png');

    animation = SpriteAnimation.fromFrameData(
      chopper,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
  }

  @override
  void onTapDown(TapDownInfo details) {
    super.onTapDown(details);
    final position = details.eventPosition.game;
    final spriteSize = Vector2.all(10);
    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize,
    );
    add(ChopperBody(position, animationComponent));
  }
}
