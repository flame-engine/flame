import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MouseCursorExample extends FlameGame with MouseMovementDetector {
  static const String description = '''
    Example showcasing the ability to change the game cursor in runtime
    hover the little square to see the cursor changing
  ''';

  static const speed = 200;
  static final Paint _blue = BasicPalette.blue.paint();
  static final Paint _white = BasicPalette.white.paint();
  static final Vector2 objSize = Vector2.all(150);

  Vector2 position = Vector2(100, 100);
  Vector2? target;

  bool onTarget = false;

  @override
  void onMouseMove(PointerHoverInfo info) {
    target = info.eventPosition.widget;
  }

  Rect _toRect() => position.toPositionedRect(objSize);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      _toRect(),
      onTarget ? _blue : _white,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final target = this.target;
    if (target != null) {
      final hovering = _toRect().contains(target.toOffset());
      if (hovering) {
        if (!onTarget) {
          //Entered
          mouseCursor = SystemMouseCursors.grab;
        }
      } else {
        if (onTarget) {
          // Exited
          mouseCursor = SystemMouseCursors.move;
        }
      }
      onTarget = hovering;
    }
  }
}
