import 'package:dashbook/dashbook.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

Widget customPainterBuilder(DashbookContext ctx) {
  return GameWidget(
    game: CustomPainterGame(),
    overlayBuilderMap: {
      'HappyFace': (context, game) {
        return Center(
          child: Container(
            color: Colors.white,
            width: 200,
            height: 200,
            child: Column(
              children: [
                const Text(
                  'Hey, I can be a widget too!',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 132,
                  width: 132,
                  child: CustomPaint(painter: PlayerCustomPainter()),
                ),
              ],
            ),
          ),
        );
      },
    },
  );
}

class PlayerCustomPainter extends CustomPainter {
  late final facePaint = Paint()..color = Colors.yellow;

  late final eyesPaint = Paint()..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    final faceRadius = size.height / 2;

    canvas.drawCircle(
      Offset(
        faceRadius,
        faceRadius,
      ),
      faceRadius,
      facePaint,
    );

    final eyeSize = faceRadius * 0.15;

    canvas.drawCircle(
      Offset(
        faceRadius - (eyeSize * 2),
        faceRadius - eyeSize,
      ),
      eyeSize,
      eyesPaint,
    );

    canvas.drawCircle(
      Offset(
        faceRadius + (eyeSize * 2),
        faceRadius - eyeSize,
      ),
      eyeSize,
      eyesPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class Player extends CustomPainterComponent with HasGameRef<CustomPainterGame> {
  static const speed = 150;

  int direction = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    painter = PlayerCustomPainter();
    size = Vector2.all(100);

    y = 200;
  }

  @override
  void update(double dt) {
    super.update(dt);

    x += speed * direction * dt;

    if ((x + width >= gameRef.size.x && direction > 0) ||
        (x <= 0 && direction < 0)) {
      direction *= -1;
    }
  }
}

class CustomPainterGame extends FlameGame with TapDetector {
  static const info = '''
      Example demonstration how to use the CustomPainterComponent.

      On the screen you can see a component using a custom painter being
      rendered on a FlameGame, and if you tap, that same painter is used to
      show the happy face on a widget overlay.
  ''';

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(Player());
  }

  @override
  void onTap() {
    if (overlays.isActive('HappyFace')) {
      overlays.remove('HappyFace');
    } else {
      overlays.add('HappyFace');
    }
  }
}
