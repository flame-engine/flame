import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';

class EffectControllersExample extends FlameGame {
  static const description = '''
    This page demonstrates application of various non-standard effect 
    controllers.
    
    The first white square has a ZigzagEffectController with period 1. The
    orange square next to it has two move effects, each with a 
    ZigzagEffectController.
  ''';

  @override
  void onMount() {
    camera.viewport = FixedResolutionViewport(Vector2(400, 600));
    add(
      RectangleComponent.square(
        position: Vector2(20, 50),
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
        position: Vector2(70, 50),
        size: 20,
        paint: Paint() ..color=const Color(0xffffbc63),
      )..addAll([
        MoveEffect.by(
          Vector2(0, 20),
          InfiniteEffectController(ZigzagEffectController(period: 8/7)),
        ),
        MoveEffect.by(
          Vector2(10, 0),
          InfiniteEffectController(ZigzagEffectController(period: 2/3)),
        ),
      ]),
    );

  }
}
