import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

/// Includes an example including advanced detectors
class MultitapExample extends FlameGame with TapCallbacks {
  static const String description = '''
    In this example we showcase the multi touch capabilities
    Touch multiple places on the screen and you will see multiple squares drawn,
    one under each finger.
  ''';

  static final whitePaint = BasicPalette.white.paint();
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  @override
  void onTapDown(TapDownEvent event) {
    taps[event.pointerId] = event.canvasPosition.toPositionedRect(tapSize);
  }

  @override
  void onTapUp(TapUpEvent event) {
    taps.remove(event.pointerId);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    taps.remove(event.pointerId);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    taps.values.forEach((rect) {
      canvas.drawRect(rect, whitePaint);
    });
  }
}
