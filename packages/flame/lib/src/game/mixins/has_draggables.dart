import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasDraggables on FlameGame {
  @mustCallSuper
  bool onDragStart(int pointerId, DragStartInfo info) {
    return propagateToChildren<Draggable>(
      (c) => c.handleDragStart(pointerId, info),
    );
  }

  @mustCallSuper
  bool onDragUpdate(int pointerId, DragUpdateInfo details) {
    return propagateToChildren<Draggable>(
      (c) => c.handleDragUpdated(pointerId, details),
    );
  }

  @mustCallSuper
  bool onDragEnd(int pointerId, DragEndInfo details) {
    return propagateToChildren<Draggable>(
      (c) => c.handleDragEnded(pointerId, details),
    );
  }

  @mustCallSuper
  bool onDragCancel(int pointerId) {
    return propagateToChildren<Draggable>(
      (c) => c.handleDragCanceled(pointerId),
    );
  }
}
