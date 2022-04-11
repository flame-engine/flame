import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

import '../components/component.dart';
import 'viewport.dart';

/// A rectangular viewport with fixed dimensions.
///
/// You can change the size of this viewport at runtime, but it will not
/// auto-resize when its parent changes size.
class FixedSizeViewport extends Viewport {
  FixedSizeViewport(
    double width,
    double height, {
    Iterable<Component>? children,
  }) : super(children: children) {
    size = Vector2(width, height);
    onViewportResize();
  }

  late Rect _clipRect;

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  void onViewportResize() {
    final x = size.x / 2;
    final y = size.y / 2;
    _clipRect = Rect.fromLTRB(-x, -y, x, y);
  }
}
