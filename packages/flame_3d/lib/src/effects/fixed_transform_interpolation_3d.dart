import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/effects/transform_effects_3d.dart'
    show slerpShortestInto;

/// Mixin on [Component3D] providing zero-allocation fixed-timestep transform
/// interpolation (`position`, `scale`, and shortest-hemisphere `Quaternion`
/// Slerp) for smooth high-refresh-rate (`90Hz` / `120Hz` / `144Hz`) rendering
/// over fixed-rate physics.
mixin FixedTransformInterpolation3D on Component3D {
  final Vector3 _prevPosition = Vector3.zero();
  final Quaternion _prevRotation = Quaternion.identity();
  final Vector3 _prevScale = Vector3.all(1);

  final Vector3 _currPosition = Vector3.zero();
  final Quaternion _currRotation = Quaternion.identity();
  final Vector3 _currScale = Vector3.all(1);

  bool _hasFixedState = false;
  bool _isInterpolated = false;

  /// Whether the component's live transform currently holds an interpolated
  /// render pose awaiting [restoreSimulatedState].
  bool get isInterpolated => _isInterpolated;

  @override
  void onMount() {
    super.onMount();
    teleportFixedState();
  }

  /// Snapshots the current simulated transform as the previous fixed-tick
  /// baseline before stepping physics.
  void captureFixedState() {
    if (_isInterpolated) {
      restoreSimulatedState();
    }
    _prevPosition.setFrom(position);
    _prevRotation
      ..setFrom(rotation)
      ..normalize();
    _prevScale.setFrom(scale);
    _currPosition.setFrom(position);
    _currRotation.setFrom(_prevRotation);
    _currScale.setFrom(scale);
    _hasFixedState = true;
  }

  /// Records the newly simulated fixed-tick transform after stepping physics.
  void commitFixedState() {
    _currPosition.setFrom(position);
    _currRotation
      ..setFrom(rotation)
      ..normalize();
    _currScale.setFrom(scale);
    _hasFixedState = true;
    _isInterpolated = false;
  }

  /// Snaps both previous and current fixed-tick states to the component's live
  /// transform so instant teleports or spawns never streak across frames.
  void teleportFixedState() {
    _prevPosition.setFrom(position);
    _prevRotation
      ..setFrom(rotation)
      ..normalize();
    _prevScale.setFrom(scale);
    _currPosition.setFrom(position);
    _currRotation.setFrom(_prevRotation);
    _currScale.setFrom(scale);
    _hasFixedState = true;
    _isInterpolated = false;
  }

  /// Applies the interpolated render pose for [alpha] in `[0..1]` between the
  /// previous and current fixed-tick transforms.
  void applyInterpolationAlpha(double alpha) {
    if (!_hasFixedState) {
      teleportFixedState();
      return;
    }
    if (!_isInterpolated) {
      commitFixedState();
    }
    final t = alpha.clamp(0.0, 1.0);
    _isInterpolated = true;

    position.setValues(
      _prevPosition.x + (_currPosition.x - _prevPosition.x) * t,
      _prevPosition.y + (_currPosition.y - _prevPosition.y) * t,
      _prevPosition.z + (_currPosition.z - _prevPosition.z) * t,
    );
    scale.setValues(
      _prevScale.x + (_currScale.x - _prevScale.x) * t,
      _prevScale.y + (_currScale.y - _prevScale.y) * t,
      _prevScale.z + (_currScale.z - _prevScale.z) * t,
    );
    slerpShortestInto(_prevRotation, _currRotation, t, this);
  }

  /// Restores the exact simulated fixed-tick transform after rendering so
  /// subsequent physics ticks never accumulate render-interpolation values.
  void restoreSimulatedState() {
    if (!_hasFixedState || !_isInterpolated) {
      return;
    }
    position.setFrom(_currPosition);
    rotation.setValues(
      _currRotation.x,
      _currRotation.y,
      _currRotation.z,
      _currRotation.w,
    );
    scale.setFrom(_currScale);
    _isInterpolated = false;
  }
}
