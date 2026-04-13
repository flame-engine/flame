import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class LongPressExample extends FlameGame {
  static const String description = '''
    In this example we show how to use `LongPressCallbacks`.\n\n
    The colored squares will turn red when a long press is recognized,
    follow the pointer while held, and turn back to green when released.
  ''';

  @override
  Future<void> onLoad() async {
    world.add(
      LongPressSquare(
        paint: BasicPalette.blue.paint(),
        position: Vector2(-100, 0),
      ),
    );
    world.add(
      LongPressSquare(
        paint: BasicPalette.green.paint(),
        position: Vector2(100, 0),
      ),
    );
  }
}

class LongPressSquare extends RectangleComponent with LongPressCallbacks {
  LongPressSquare({required Paint paint, required Vector2 position})
    : _originalPaint = paint,
      super(
        position: position,
        size: Vector2.all(100),
        paint: paint,
        anchor: Anchor.center,
      );

  final Paint _originalPaint;

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    paint = BasicPalette.red.paint();
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event);
    paint = Paint()..color = const Color(0xFF00FF00);
  }

  @override
  void onLongPressCancel(LongPressCancelEvent event) {
    super.onLongPressCancel(event);
    paint = _originalPaint;
  }
}
