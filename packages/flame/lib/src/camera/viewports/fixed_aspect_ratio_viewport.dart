import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/src/camera/viewport.dart';
import 'package:vector_math/vector_math_64.dart';

/// [FixedAspectRatioViewport] is a rectangular viewport which auto-expands to
/// take as much space as possible within the canvas, while maintaining a fixed
/// aspect ratio.
///
/// This viewport will automatically adjust its size and position when the
/// game canvas changes in size.
class FixedAspectRatioViewport extends Viewport {
  FixedAspectRatioViewport({
    required this.aspectRatio,
    super.children,
  })  : _canvasSize = Vector2.zero(),
        assert(aspectRatio > 0);

  /// The ratio of width to height of the viewport.
  final double aspectRatio;

  final Vector2 _canvasSize;
  Rect _clipRect = Rect.zero;

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _canvasSize.setFrom(canvasSize);
    onViewportResize();
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
    final availableWidth = _canvasSize.x;
    final availableHeight = _canvasSize.y;
    if (availableHeight * aspectRatio > availableWidth) {
      size.x = availableWidth;
      size.y = availableWidth / aspectRatio;
    } else {
      size.x = availableHeight * aspectRatio;
      size.y = availableHeight;
    }
    position.x = (availableWidth - size.x) / 2 + anchor.x * size.x;
    position.y = (availableHeight - size.y) / 2 + anchor.y * size.y;
    _clipRect = Rect.fromLTRB(0, 0, size.x, size.y);
  }
}
