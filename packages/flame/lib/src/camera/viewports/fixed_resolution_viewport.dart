import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:meta/meta.dart';

/// [FixedAspectRatioViewport] is a rectangular viewport which auto-expands to
/// take as much space as possible within the canvas, while maintaining a fixed
/// aspect ratio.
///
/// This viewport will automatically adjust its size and position when the
/// game canvas changes in size. At the same time, manually changing the size
/// of this viewport is not supported.
class FixedResolutionViewport extends FixedAspectRatioViewport {
  FixedResolutionViewport({
    required this.resolution,
    super.children,
  }) : super(aspectRatio: resolution.x / resolution.y);

  /// The resolution that the viewport should adhere to.
  final Vector2 resolution;

  @internal
  final Transform2D transform = Transform2D();

  @override
  Vector2 get scale => transform.scale;

  final Vector2 _scaleVector = Vector2.zero();

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= size.x && y <= size.y;
  }

  @override
  void onViewportResize() {
    super.onViewportResize();
    final scaleX = size.x / resolution.x;
    final scaleY = size.y / resolution.y;
    _scaleVector.setAll(min(scaleX, scaleY));
    transform.scale = _scaleVector;
    camera.viewfinder.visibleRect = null;
  }

  @override
  Vector2 globalToLocal(Vector2 point, {Vector2? output}) {
    final scaledPoint = transform.globalToLocal(point, output: output);
    return super.globalToLocal(scaledPoint, output: output);
  }

  @override
  void transformCanvas(Canvas canvas) {
    // TODO(Lukas): Don't create new objects here.
    clip(canvas);
    canvas.translateVector(size / 2);
    canvas.transform2D(transform);
    canvas.translateVector(-((size / 2) / scale.x));
    //canvas.translateVector(-(size / 2));
  }
}
