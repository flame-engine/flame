import 'package:flutter/foundation.dart';

import '../../gestures.dart';
import '../base_component.dart';
import '../../extensions/offset.dart';
import '../../game/base_game.dart';

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
    components.forEach((c) {
      if (c is BaseComponent) {
        c.propagateToChildren<Dragable>(
          (child) => child.handleReceiveDrag(details),
        );
      }
    });
  }
}
