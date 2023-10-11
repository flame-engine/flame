import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

/// Showcases how to mix two advanced detectors
class MultitapAdvancedExample extends FlameGame
    with MultiTouchTapDetector, MultiTouchDragDetector {
  static const String description = '''
    This showcases the use of both `MultiTouchTapDetector` and
    `MultiTouchDragDetector` simultaneously. Drag multiple fingers on the screen
    to see rectangles of different sizes being drawn.
  ''';

  static final whitePaint = BasicPalette.white.paint();
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  Vector2? start;
  Vector2? end;
  Rect? panRect;

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
  void onDragCancel(int pointerId) {
    end = null;
    start = null;
    panRect = null;
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    end = null;
    start = info.eventPosition.widget;
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    end = info.eventPosition.widget;
  }

  @override
  void onDragEnd(int pointerId, _) {
    final start = this.start;
    final end = this.end;
    if (start != null && end != null) {
      panRect = start.toPositionedRect(end - start);
    }
  }

  @override
  void render(Canvas canvas) {
    final panRect = this.panRect;
    super.render(canvas);
    taps.values.forEach((rect) {
      canvas.drawRect(rect, whitePaint);
    });

    if (panRect != null) {
      canvas.drawRect(panRect, whitePaint);
    }
  }
}
