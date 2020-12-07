import 'package:flutter/foundation.dart';

import '../../gestures.dart';
import '../base_component.dart';
import '../../extensions/offset.dart';
import '../../game/base_game.dart';
import '../component.dart';

mixin Dragable on BaseComponent {
  bool onReceiveDrag(DragEvent details) {
    return true;
  }

  bool handleReceiveDrag(DragEvent details) {
    if (checkOverlap(details.initialPosition.toVector2())) {
      return onReceiveDrag(details);
    }
    return true;
  }
}

mixin HasDragableComponents on BaseGame {
  @mustCallSuper
  void onReceiveDrag(DragEvent details) {
    final dragEventHandler = (Dragable c) => c.handleReceiveDrag(details);

    for (Component c in components.toList().reversed) {
      bool shouldContinue = true;
      if (c is BaseComponent) {
        shouldContinue = c.propagateToChildren<Dragable>(dragEventHandler);
      }
      if (c is Dragable && shouldContinue) {
        shouldContinue = dragEventHandler(c);
      }
      if (!shouldContinue) {
        break;
      }
    }
  }
}
