import 'dart:ui';

import 'package:flame/position.dart';
import 'package:flutter/gestures.dart';

mixin Tapable<T extends Position> {
  T gameCanvasScale;
  Rect toRect();

  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  bool checkTapOverlap(Offset o) => toRect().contains(o.scale(1.0 / gameCanvasScale.x, 1.0 / gameCanvasScale.y));

  void handleTapDown(TapDownDetails details) {
    if (checkTapOverlap(details.globalPosition)) {
      onTapDown(details);
    }
    tapableChildren().forEach((c) => c.handleTapDown(details));
  }

  void handleTapUp(TapUpDetails details) {
    if (checkTapOverlap(details.globalPosition)) {
      onTapUp(details);
    }
    tapableChildren().forEach((c) => c.handleTapUp(details));
  }

  void handleTapCancel() {
    onTapCancel();
    tapableChildren().forEach((c) => c.handleTapCancel());
  }

  /// Overwrite this to add children to this [Tapable].
  ///
  /// If a [Tapable] has children, its children be taped as well.
  Iterable<Tapable> tapableChildren() => [];
}
