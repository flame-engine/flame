import 'dart:ui';

import 'package:flutter/gestures.dart';

mixin Tapeable {
  Rect toRect();

  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}

  bool checkTapOverlap(Offset o) => toRect().contains(o);

  void handleTapDown(TapDownDetails details) {
    if (checkTapOverlap(details.globalPosition)) {
      onTapDown(details);
    }
    tapeableChildren().forEach((c) => c.handleTapDown(details));
  }

  void handleTapUp(TapUpDetails details) {
    if (checkTapOverlap(details.globalPosition)) {
      onTapUp(details);
    }
    tapeableChildren().forEach((c) => c.handleTapUp(details));
  }

  void handleTapCancel() {
    onTapCancel();
    tapeableChildren().forEach((c) => c.handleTapCancel());
  }

  /// Overwrite this to add children to this [Tapeable].
  ///
  /// If a [Tapeable] has children, its children be taped as well.
  Iterable<Tapeable> tapeableChildren() => [];
}
