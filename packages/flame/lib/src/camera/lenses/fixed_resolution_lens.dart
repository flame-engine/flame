import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/camera/lenses/lens.dart';

/// This viewfinder is used in combination with with the
/// [FixedAspectRatioViewport] to emulate a fixed resolution viewport in the
/// [CameraComponent].
class FixedResolutionLens extends Lens {
  FixedResolutionLens({required double width, required double height})
      : _fixedResolution = Vector2(width, height);

  final Vector2 _fixedResolution;

  final Vector2 _scaleVector = Vector2.zero();

  /// Set the scale level based on the [_fixedResolution] and the viewport size.
  @override
  void onViewportResize() {
    final viewportSize = camera.viewport.size;
    final scaleX = viewportSize.x / _fixedResolution.x;
    final scaleY = viewportSize.y / _fixedResolution.y;
    _scaleVector.setAll(
      min(scaleX, scaleY),
    );
    transform.scale = _scaleVector;
    camera.viewfinder.visibleRect = null;
  }

  @override
  void onGameResize(Vector2 size) {
    onViewportResize();
    super.onGameResize(size);
  }
}
