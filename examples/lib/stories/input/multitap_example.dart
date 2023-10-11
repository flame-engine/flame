import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

/// Includes an example including advanced detectors
class MultitapExample extends FlameGame with MultiTouchTapDetector {
  static const String description = '''
    In this example we showcase the multi touch capabilities
    Touch multiple places on the screen and you will see multiple squares drawn,
    one under each finger.
  ''';

  static final whitePaint = BasicPalette.white.paint();
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    taps[pointerId] = info.eventPosition.widget.toPositionedRect(tapSize);
  }

  @override
  void onTapUp(int pointerId, _) {
    taps.remove(pointerId);
  }

  @override
  void onTapCancel(int pointerId) {
    taps.remove(pointerId);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    taps.values.forEach((rect) {
      canvas.drawRect(rect, whitePaint);
    });
  }
}
