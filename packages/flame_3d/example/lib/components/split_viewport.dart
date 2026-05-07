import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';

enum SplitSide { left, right }

/// A viewport that occupies one half of the screen while maintaining a fixed
/// virtual resolution, similar to [FixedResolutionViewport] but positioned in
/// the left or right half for split-screen setups.
class SplitViewport extends Viewport {
  SplitViewport({
    required this.resolution,
    required this.side,
    super.children,
  });

  final Vector2 resolution;
  final SplitSide side;

  Rect _clipRect = Rect.zero;
  final Vector2 _scale = Vector2.zero();

  @override
  Vector2 get virtualSize => resolution;

  @override
  void onLoad() {
    _handleResize(findGame()!.canvasSize);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    _handleResize(canvasSize);
  }

  void _handleResize(Vector2 canvasSize) {
    final halfWidth = canvasSize.x / 2;
    final availableHeight = canvasSize.y;
    final aspectRatio = resolution.x / resolution.y;

    // Fit within the half while maintaining aspect ratio.
    if (availableHeight * aspectRatio > halfWidth) {
      size = Vector2(halfWidth, halfWidth / aspectRatio);
    } else {
      size = Vector2(availableHeight * aspectRatio, availableHeight);
    }

    // Center within the assigned half.
    final yOffset = (availableHeight - size.y) / 2;
    final xOffset = switch (side) {
      SplitSide.left => (halfWidth - size.x) / 2,
      SplitSide.right => halfWidth + (halfWidth - size.x) / 2,
    };
    position.setValues(
      xOffset + anchor.x * size.x,
      yOffset + anchor.y * size.y,
    );

    _clipRect = Rect.fromLTRB(0, 0, size.x, size.y);

    // Scale from pixel size to virtual resolution.
    final s = min(size.x / resolution.x, size.y / resolution.y);
    _scale.setAll(s);
  }

  @override
  void clip(Canvas canvas) => canvas.clipRect(_clipRect, doAntiAlias: false);

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= virtualSize.x && y <= virtualSize.y;
  }

  @override
  void onViewportResize() {}

  @override
  void transformCanvas(Canvas canvas) {
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(_scale.x, _scale.y);
    canvas.translate(-resolution.x / 2, -resolution.y / 2);
  }
}
