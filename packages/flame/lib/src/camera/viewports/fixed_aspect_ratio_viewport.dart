import 'dart:ui';

import 'package:flame/src/camera/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

/// [FixedAspectRatioViewport] is a rectangular viewport which auto-expands to
/// take as much space as possible within the canvas, while maintaining a fixed
/// aspect ratio.
///
/// This viewport will automatically adjust its size and position when the
/// game canvas changes in size. At the same time, manually changing the size
/// of this viewport is not supported.
class FixedAspectRatioViewport extends Viewport {
  FixedAspectRatioViewport({
    required this.aspectRatio,
    super.children,
  }) : assert(aspectRatio > 0);

  /// The ratio of width to height of the viewport.
  final double aspectRatio;

  Rect _clipRect = Rect.zero;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    final availableWidth = canvasSize.x;
    final availableHeight = canvasSize.y;
    size = (availableHeight * aspectRatio > availableWidth)
        ? Vector2(availableWidth, availableWidth / aspectRatio)
        : Vector2(availableHeight * aspectRatio, availableHeight);
    position.x = (availableWidth - size.x) / 2 + anchor.x * size.x;
    position.y = (availableHeight - size.y) / 2 + anchor.y * size.y;
    _clipRect = Rect.fromLTRB(0, 0, size.x, size.y);
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= size.x && y <= size.y;
  }

  @override
  void onViewportResize() {
    final desiredWidth = size.y * aspectRatio;
    if (desiredWidth > size.x) {
      size.y = size.x / aspectRatio;
    } else {
      size.x = desiredWidth;
    }

    final x = size.x / 2;
    final y = size.y / 2;
    _clipRect = Rect.fromLTRB(-x, -y, x, y);
  }
}
