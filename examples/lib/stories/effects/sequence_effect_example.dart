import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';

class SequenceEffectExample extends FlameGame {
  static const String description = '''
    Sequence of effects, consisting of a move effect, a rotate effect, another
    move effect, a scale effect, and then one more move effect. The sequence
    then runs in the opposite order (alternate = true) and loops infinitely
    (infinite = true).
  ''';

  @override
  Future<void> onLoad() async {
    EffectController duration(double x) => EffectController(duration: x);
    add(
      Player()
        ..position = Vector2(200, 300)
        ..add(
          SequenceEffect(
            [
              MoveEffect.to(Vector2(400, 300), duration(0.7)),
              RotateEffect.by(tau / 4, duration(0.5)),
              MoveEffect.to(Vector2(400, 400), duration(0.7)),
              ScaleEffect.by(Vector2.all(1.5), duration(0.7)),
              MoveEffect.to(Vector2(400, 500), duration(0.7)),
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
