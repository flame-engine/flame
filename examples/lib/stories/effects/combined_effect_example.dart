import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class CombinedEffectExample extends FlameGame {
  static const String description = '''
    A combination of effects, consisting of a move effect, a rotate effect, and
    a scale effect. The combination of effects then runs in the opposite order
    (alternate = true) and loops infinitely (infinite = true).
  ''';

  @override
  Future<void> onLoad() async {
    EffectController duration(double x) => EffectController(duration: x);
    add(
      Player()
        ..position = Vector2(200, 300)
        ..add(
          CombinedEffect(
            [
              MoveEffect.by(Vector2(200, 0), duration(1)),
              RotateEffect.by(tau / 4, duration(2)),
              ScaleEffect.by(Vector2.all(1.5), duration(1)),
            ],
            alternate: true,
            infinite: true,
          ),
        ),
    );
  }
}

class Player extends PositionComponent {
  Player()
    : path = Path()
        ..lineTo(40, 20)
        ..lineTo(0, 40)
        ..quadraticBezierTo(8, 20, 0, 0)
        ..close(),
      bodyPaint = Paint()..color = const Color(0x887F99B3),
      borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFFD9A),
      super(anchor: Anchor.center, size: Vector2(40, 40));

  final Path path;
  final Paint borderPaint;
  final Paint bodyPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(path, bodyPaint);
    canvas.drawPath(path, borderPaint);
  }
}
