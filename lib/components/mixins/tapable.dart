import 'dart:ui';

import 'package:flame/components/position_component.dart';
import 'package:flutter/gestures.dart';

mixin Tapable on PositionComponent {
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  bool checkTapOverlap(Rect rect, Offset o) => rect.contains(o);

  void handleTapDown(Rect rect, TapDownDetails details) {
    if (checkTapOverlap(rect, details.localPosition)) {
      onTapDown(details);
    }
  }

  void handleTapUp(Rect rect, TapUpDetails details) {
    if (checkTapOverlap(rect, details.localPosition)) {
      onTapUp(details);
    }
  }

  void handleTapCancel() {
    onTapCancel();
  }
}
