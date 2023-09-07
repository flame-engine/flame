import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/animation.dart';

class ScaleEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    In this example you can tap the screen and the component will scale up or
    down, depending on its current state.
    
    The star pulsates randomly using a RandomEffectController.
  ''';

  late RectangleComponent square;
  bool grow = true;

  @override
  Future<void> onLoad() async {
    square = RectangleComponent.square(
      size: 100,
      position: Vector2.all(200),
      paint: BasicPalette.white.paint()..style = PaintingStyle.stroke,
    );
    final childSquare = RectangleComponent.square(
      position: Vector2.all(70),
      size: 20,
    );
    square.add(childSquare);
    add(square);

    add(
      Star()
        ..position = Vector2(200, 100)
        ..add(
          ScaleEffect.to(
            Vector2.all(1.2),
            InfiniteEffectController(
              SequenceEffectController([
                LinearEffectController(0.1),
                ReverseLinearEffectController(0.1),
                RandomEffectController.exponential(
                  PauseEffectController(1, progress: 0),
                  beta: 1,
                ),
              ]),
            ),
          ),
        ),
    );
  }

  @override
  void onTap() {
    final s = grow ? 3.0 : 1.0;

    grow = !grow;

    square.add(
      ScaleEffect.to(
        Vector2.all(s),
        EffectController(
          duration: 1.5,
          curve: Curves.bounceInOut,
        ),
      ),
    );
  }
}

class Star extends PositionComponent {
  Star() {
    const smallR = 15.0;
    const bigR = 30.0;
    shape = Path()..moveTo(bigR, 0);
    for (var i = 1; i < 10; i++) {
      final r = i.isEven ? bigR : smallR;
      final a = i / 10 * tau;
      shape.lineTo(r * cos(a), r * sin(a));
    }
    shape.close();
  }

  late final Path shape;
  late final Paint paint = Paint()..color = const Color(0xFFFFF127);

  @override
  void render(Canvas canvas) {
    canvas.drawPath(shape, paint);
  }
}
