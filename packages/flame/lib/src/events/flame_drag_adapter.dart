import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

@internal
class FlameDragAdapter implements Drag {
  FlameDragAdapter(this._game, Offset startPoint)
      : _pointerId = _globallyUniqueIdCounter++,
        assert(_game is Game) {
    start(startPoint);
  }

  final MultiDragListener _game;
  final int _pointerId;
  static int _globallyUniqueIdCounter = 0;

  void start(Offset point) {
    _game.handleDragStart(
      _pointerId,
      DragStartDetails(
        globalPosition: point,
        localPosition: (_game as Game).renderBox.globalToLocal(point),
      ),
    );
  }

  @override
  void cancel() {
    _game.handleDragCancel(_pointerId);
  }

  @override
  void end(DragEndDetails details) {
    _game.handleDragEnd(_pointerId, details);
  }

  @override
  void update(DragUpdateDetails details) {
    _game.handleDragUpdate(_pointerId, details);
  }
}
