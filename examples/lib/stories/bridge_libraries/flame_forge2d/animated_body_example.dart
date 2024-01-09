import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_forge2d/utils/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class AnimatedBodyExample extends Forge2DGame {
  static const String description = '''
    In this example we show how to add an animated chopper, which is created
    with a SpriteAnimationComponent, on top of a BodyComponent.
    
    Tap the screen to add more choppers.
  ''';

  AnimatedBodyExample()
      : super(
          gravity: Vector2.zero(),
          world: AnimatedBodyWorld(),
        );
}

class AnimatedBodyWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<Forge2DGame> {
  late Image chopper;
  late SpriteAnimation animation;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    chopper = await Flame.images.load('animations/chopper.png');

    animation = SpriteAnimation.fromFrameData(
      chopper,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    final boundaries = createBoundaries(game);
    addAll(boundaries);
  }

  @override
  void onTapDown(TapDownEvent info) {
    super.onTapDown(info);
    final position = info.localPosition;
    final spriteSize = Vector2.all(10);
    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: spriteSize,
      anchor: Anchor.center,
    );
    add(ChopperBody(position, animationComponent));
  }
}

class ChopperBody extends BodyComponent {
  final Vector2 _position;
  final Vector2 size;

  ChopperBody(
    this._position,
    PositionComponent component,
  ) : size = component.size {
    renderBody = false;
    add(component);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 4;
    final fixtureDef = FixtureDef(
      shape,
      userData: this, // To be able to determine object in collision
      restitution: 0.8,
      friction: 0.2,
    );

    final velocity = (Vector2.random() - Vector2.random()) * 200;
    final bodyDef = BodyDef(
      position: _position,
      angle: velocity.angleTo(Vector2(1, 0)),
      linearVelocity: velocity,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
