import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flame/src/game/mixins/game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Helper class to convert drag API as expected by the
/// [ImmediateMultiDragGestureRecognizer] into the API expected by Flame's
/// [MultiDragListener].
@internal
class FlameDragAdapter implements Drag {
  FlameDragAdapter(this._game, Offset startPoint) {
    start(startPoint);
  }

  final MultiDragListener _game;
  late final int _id;
  static int _globalIdCounter = 0;

  void start(Offset point) {
    final event = DragStartDetails(
      globalPosition: point,
      localPosition: (_game as Game).renderBox.globalToLocal(point),
    );
    _id = _globalIdCounter++;
    _game.handleDragStart(_id, event);
  }

  @override
  void update(DragUpdateDetails event) => _game.handleDragUpdate(_id, event);

  @override
  void end(DragEndDetails event) => _game.handleDragEnd(_id, event);

  @override
  void cancel() => _game.handleDragCancel(_id);
}
