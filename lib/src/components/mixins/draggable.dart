import 'package:flutter/foundation.dart';

import '../../gestures.dart';
import '../base_component.dart';
import '../../extensions/offset.dart';
import '../../game/base_game.dart';
import '../component.dart';

mixin Draggable on BaseComponent {
  bool onReceiveDrag(DragEvent event) {
    return true;
  }

  bool handleReceiveDrag(DragEvent event) {
    if (checkOverlap(event.initialPosition.toVector2())) {
      return onReceiveDrag(event);
    }
    return true;
  }
}

mixin HasDraggableComponents on BaseGame {
  @mustCallSuper
  void onReceiveDrag(DragEvent event) {
    final dragEventHandler = (Draggable c) => c.handleReceiveDrag(event);

    for (Component c in components.toList().reversed) {
      bool shouldContinue = true;
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<Draggable>(dragEventHandler);
      }
      if (c is Draggable && shouldContinue) {
        shouldContinue = dragEventHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }
}
