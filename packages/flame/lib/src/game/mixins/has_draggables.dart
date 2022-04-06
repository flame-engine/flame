import 'package:meta/meta.dart';

import '../../../components.dart';
import '../../../game.dart';
import '../../gestures/events.dart';

mixin HasDraggables on FlameGame {
  @mustCallSuper
  void onDragStart(int pointerId, DragStartInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragStart(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragUpdated(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragEnd(int pointerId, DragEndInfo info) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragEnded(pointerId, info),
    );
  }

  @mustCallSuper
  void onDragCancel(int pointerId) {
    propagateToChildren<Draggable>(
      (c) => c.handleDragCanceled(pointerId),
    );
  }
}
