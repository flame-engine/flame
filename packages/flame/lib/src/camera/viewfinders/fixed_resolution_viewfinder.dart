import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/game/transform2d.dart';
import 'package:meta/meta.dart';

/// This viewfinder is used in combination with with the
/// [FixedAspectRatioViewport] to emulate a fixed resolution viewport in the
/// [CameraComponent].
class FixedResolutionViewfinder extends Viewfinder {
  FixedResolutionViewfinder({required double width, required double height})
      : _fixedResolution = Vector2(width, height) {
    super.transform.addListener(updateInternalTransform);
  }

  /// Internal transform matrix which is the same as [super.transform], but with
  /// [_preScale] applied to achieve the fixed resolution that has been asked
  /// for.
  final Transform2D _transform = Transform2D();

  final Vector2 _fixedResolution;

  @internal
  @override
  Transform2D get transform => _transform;

  void updateInternalTransform() {
    _scaleVector
      ..setAll(_preScale)
      ..multiply(super.transform.scale);
    _transform
      ..setFrom(super.transform)
      ..scale = _scaleVector;
  }

  /// Vector used to store the [_preScale] before applied to the final
  /// transform.
  final Vector2 _scaleVector = Vector2.zero();

  /// The extra scaling that is being done to achieve the fixed resolution
  /// requested by the user.
  @override
  double get preScale => _preScale;
  double _preScale = 1.0;

  /// Set [preScale] level based on the [_fixedResolution].
  void _updatePreScale() {
    if (parent != null && visibleGameSize == null) {
      final viewportSize = camera.viewport.size;
      final preScaleX = viewportSize.x / _fixedResolution.x;
      final preScaleY = viewportSize.y / _fixedResolution.y;
      _preScale = min(preScaleX, preScaleY);
      visibleRect = null;
      updateInternalTransform();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    _updatePreScale();
    super.onGameResize(size);
  }
}
