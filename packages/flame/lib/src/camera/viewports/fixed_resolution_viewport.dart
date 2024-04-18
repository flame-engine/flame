import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/effects/provider_interfaces.dart';

/// The [FixedResolutionViewport] is a rectangular viewport which auto-expands
/// to take as much space as possible within the canvas, while maintaining a
/// fixed resolution and aspect ratio. I.e. the viewport will always show the
/// same portion ([resolution]) of the game world, regardless of the size of the
/// canvas.
///
/// This viewport will automatically adjust its size and position when the
/// game canvas changes in size. At the same time, manually changing the size
/// of this viewport is not supported.
class FixedResolutionViewport extends FixedAspectRatioViewport
    implements ReadOnlyScaleProvider {
  FixedResolutionViewport({
    required this.resolution,
    super.children,
  }) : super(aspectRatio: resolution.x / resolution.y);

  /// The resolution that the viewport should adhere to.
  final Vector2 resolution;

  @override
  Vector2 get virtualSize => resolution;

  @override
  Vector2 get scale => transform.scale;

  final Vector2 _scaleVector = Vector2.zero();

  @override
  bool containsLocalPoint(Vector2 point) {
    final x = point.x;
    final y = point.y;
    return x >= 0 && y >= 0 && x <= virtualSize.x && y <= virtualSize.y;
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
    final viewportPoint = super.globalToLocal(point, output: output);
    return transform.globalToLocal(viewportPoint, output: output);
  }

  @override
  Vector2 localToGlobal(Vector2 point, {Vector2? output}) {
    final viewportPoint = transform.localToGlobal(point, output: output);
    return super.localToGlobal(viewportPoint, output: output);
  }

  @override
  void transformCanvas(Canvas canvas) {
    canvas.translate(size.x / 2, size.y / 2);
    super.transformCanvas(canvas);
    canvas.translate(-(size.x / 2) / scale.x, -(size.y / 2) / scale.y);
  }
}
