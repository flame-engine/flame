import 'dart:ui';

import 'package:flutter/gestures.dart';

mixin Tapable {
  Rect toRect();

  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  int _currentPointerId;

  bool _checkPointerId(int pointerId) => _currentPointerId == pointerId;

  bool checkTapOverlap(Offset o) => toRect().contains(o);

  void handleTapDown(int pointerId, TapDownDetails details) {
    if (checkTapOverlap(details.localPosition)) {
      _currentPointerId = pointerId;
      onTapDown(details);
    }
    tapableChildren().forEach((c) => c.handleTapDown(pointerId, details));
  }

  void handleTapUp(int pointerId, TapUpDetails details) {
    if (_checkPointerId(pointerId) && checkTapOverlap(details.localPosition)) {
      _currentPointerId = null;
      onTapUp(details);
    }
    tapableChildren().forEach((c) => c.handleTapUp(pointerId, details));
  }

  void handleTapCancel(int pointerId) {
    if (_checkPointerId(pointerId)) {
      _currentPointerId = null;
      onTapCancel();
    }
    tapableChildren().forEach((c) => c.handleTapCancel(pointerId));
  }

  /// Overwrite this to add children to this [Tapable].
  ///
  /// If a [Tapable] has children, its children be taped as well.
  Iterable<Tapable> tapableChildren() => [];
}
