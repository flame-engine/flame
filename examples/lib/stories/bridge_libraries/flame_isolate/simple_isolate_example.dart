import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_isolate/flame_isolate.dart';
import 'package:flutter/painting.dart';

class SimpleIsolateExample extends FlameGame with FlameIsolate, TapDetector {
  static const String description = '''
    This example showcases a simple FlameIsolate example.
  ''';

  @override
  BackpressureStrategy get backpressureStrategy => NoBackPressureStrategy();

  Rect get button => const Rect.fromLTWH(40, 40, 200, 100);

  static Paint black = BasicPalette.black.paint();
  static Paint gray = const PaletteEntry(Color(0xFFCCCCCC)).paint();
  static TextPaint text = TextPaint(
    style: TextStyle(color: BasicPalette.white.color),
  );

  @override
  Future<void>? onLoad() {}

  void fireOne() {}

  void fireTwo() {}

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), black);

    text.render(
      canvas,
      '(click anywhere for 1)',
      Vector2(size.x / 2, 200),
      anchor: Anchor.topCenter,
    );

    canvas.drawRect(button, gray);

    text.render(
      canvas,
      'click here for 2',
      Vector2(size.x / 2, size.y - 200),
      anchor: Anchor.bottomCenter,
    );
  }

  @override
  void onTapDown(TapDownInfo details) {
    if (button.containsPoint(details.eventPosition.game)) {
      fireTwo();
    } else {
      fireOne();
    }
  }
}


