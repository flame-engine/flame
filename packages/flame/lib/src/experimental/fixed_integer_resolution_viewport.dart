import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

/// This viewport is a very similar to [FixedResolutionViewport], but allows
/// for better handling of viewing pixel art. The main point is it ensures
/// sprites align to the physical pixel grid and only scales at integer
/// intervals. This prevents artifacts or distortion happening to scaled up
/// pixel art as discussed in https://github.com/flame-engine/flame/issues/1152.
/// Remember to set [devicePixelRatio] before using the viewport; a good place
/// to update it is in handleResize of your game, directly from
/// WidgetBindings.instance.window.devicePixelRatio.
class FixedIntegerResolutionViewport extends Viewport {
  /// By default, this viewport will clip anything rendered outside.
  /// Use this variable to control that behavior.
  bool clip;
  double devicePixelRatio = 1.0;

  @override
  late Vector2 effectiveSize;

  final Vector2 _scaledSize = Vector2.zero();
  Vector2 get scaledSize => _scaledSize.clone();

  final Vector2 _resizeOffset = Vector2.zero();
  Vector2 get resizeOffset =>
      _resizeOffset.clone()..scale(1 / devicePixelRatio);

  late double _scale;
  double get scale => _scale / devicePixelRatio;

  /// The matrix used for scaling and translating the canvas
  final Matrix4 _transform = Matrix4.identity();

  /// The Rect that is used to clip the canvas
  late Rect _clipRect;

  FixedIntegerResolutionViewport(this.effectiveSize, {this.clip = true});

  @override
  void resize(Vector2 newCanvasSize) {
    canvasSize = newCanvasSize.clone();
    final devicePixels = canvasSize!..scale(devicePixelRatio);

    _scale = math
        .min(
          devicePixels.x / effectiveSize.x,
          devicePixels.y / effectiveSize.y,
        )
        .ceil()
        .toDouble();

    _scaledSize
      ..setFrom(effectiveSize)
      ..scale(_scale);
    _resizeOffset
      ..setFrom(devicePixels)
      ..sub(_scaledSize)
      ..scale(0.5)
      ..round();

    _clipRect = _resizeOffset & _scaledSize;

    _transform.setIdentity();
    _transform.translate(resizeOffset.x, resizeOffset.y);
    _transform.scale(scale, scale, 1);
  }

  @override
  void apply(Canvas c) {
    if (clip) {
      c.clipRect(_clipRect);
    }
    c.transform(_transform.storage);
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    return (worldCoordinates * scale)..add(resizeOffset);
  }

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    return (screenCoordinates - resizeOffset)..scale(1 / scale);
  }

  @override
  Vector2 scaleVector(Vector2 worldCoordinates) {
    return worldCoordinates * scale;
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / scale;
  }
}
