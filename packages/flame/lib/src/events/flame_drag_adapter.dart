import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Helper class to convert drag API as expected by the
/// [ImmediateMultiDragGestureRecognizer] into the API expected by Flame's
/// [MultiDragListener].
@internal
class FlameDragAdapter implements Drag {
  FlameDragAdapter(this._dragListener, Offset startPoint) {
    start(startPoint);
  }

  final MultiDragListener _dragListener;
  late final int _id;
  static int _globalIdCounter = 0;

  void start(Offset point) {
    final event = DragStartDetails(
      sourceTimeStamp: Duration.zero,
      globalPosition: point,
      localPosition: _dragListener.renderBox.globalToLocal(point),
    );
    _id = _globalIdCounter++;
    _dragListener.handleDragStart(_id, event);
  }

  @override
  void update(DragUpdateDetails event) =>
      _dragListener.handleDragUpdate(_id, event);

  @override
  void end(DragEndDetails event) => _dragListener.handleDragEnd(_id, event);

  @override
  void cancel() => _dragListener.handleDragCancel(_id);
}
