import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

/// Showcases how to mix tap and drag callbacks
class MultitapAdvancedExample()
    extends FlameGame
    with TapCallbacks, DragCallbacks {
  static const String description = '''
    This showcases the use of both `TapCallbacks` and `DragCallbacks`
    simultaneously. Drag multiple fingers on the screen to see rectangles of
    different sizes being drawn.
  ''';

  static final whitePaint = BasicPalette.white.paint();
  static final tapSize = Vector2.all(50);

  final Map<int, Rect> taps = {};

  _Drag? _drag;
  Rect? panRect;

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
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _drag = null;
    panRect = null;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _drag = (start: event.canvasPosition, end: null);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final drag = _drag;
    if (drag != null) {
      _drag = (start: drag.start, end: event.canvasStartPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_drag case (:final start, end: final end?)) {
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

typedef _Drag = ({Vector2 start, Vector2? end});
