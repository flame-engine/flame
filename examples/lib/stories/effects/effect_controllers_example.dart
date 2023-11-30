import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class EffectControllersExample extends FlameGame {
  static const description = '''
    This page demonstrates application of various non-standard effect 
    controllers.

    The first white square has a ZigzagEffectController with period 1. The
    orange square next to it has two move effects, each with a
    ZigzagEffectController.

    The lime square has a SineEffectController with the same period of 1s. The
    violet square next to it has two move effects, each with a
    SineEffectController with periods, but one of the effects is slightly 
    delayed.
  ''';

  EffectControllersExample()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: 400,
            height: 600,
          ),
          world: _EffectControllerWorld(),
        );
}

class _EffectControllerWorld extends World {
  @override
  void onLoad() {
    add(
      RectangleComponent.square(
        position: Vector2(-140, 0),
        size: 20,
      )..add(
          MoveEffect.by(
            Vector2(0, 20),
            InfiniteEffectController(ZigzagEffectController(period: 1)),
          ),
        ),
    );
    add(
      RectangleComponent.square(
        position: Vector2(-50, 0),
        size: 20,
        paint: Paint()..color = const Color(0xffffbc63),
      )..addAll([
          MoveEffect.by(
            Vector2(0, 20),
            InfiniteEffectController(ZigzagEffectController(period: 8 / 7)),
          ),
          MoveEffect.by(
            Vector2(10, 0),
            InfiniteEffectController(ZigzagEffectController(period: 2 / 3)),
          ),
        ]),
    );

    add(
      RectangleComponent.square(
        position: Vector2(50, 0),
        size: 20,
        paint: Paint()..color = const Color(0xffbeff63),
      )..add(
          MoveEffect.by(
            Vector2(0, 20),
            InfiniteEffectController(SineEffectController(period: 1)),
          ),
        ),
    );
    add(
      RectangleComponent.square(
        position: Vector2(140, 0),
        size: 10,
        paint: Paint()..color = const Color(0xffb663ff),
      )..addAll([
          MoveEffect.by(
            Vector2(0, 20),
            InfiniteEffectController(SineEffectController(period: 1))
              ..advance(0.25),
          ),
          MoveEffect.by(
            Vector2(10, 0),
            InfiniteEffectController(SineEffectController(period: 1)),
          ),
        ]),
    );
  }
}
