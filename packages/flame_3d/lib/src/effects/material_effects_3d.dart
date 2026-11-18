import 'dart:ui' show Color;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/src/effects/effect_3d.dart';

/// Interpolates a [MeshComponent]'s per-instance RGBA `color` to [targetColor].
class ColorTintEffect3D(
  final Color targetColor,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<MeshComponent> {
  double _startR = 1.0;
  double _startG = 1.0;
  double _startB = 1.0;
  double _startA = 1.0;

  @override
  void onStart() {
    super.onStart();
    final current = target.color;
    _startR = current.r;
    _startG = current.g;
    _startB = current.b;
    _startA = current.a;
  }

  @override
  void apply(double progress) {
    final r = (_startR + (targetColor.r - _startR) * progress).clamp(0.0, 1.0);
    final g = (_startG + (targetColor.g - _startG) * progress).clamp(0.0, 1.0);
    final b = (_startB + (targetColor.b - _startB) * progress).clamp(0.0, 1.0);
    final a = (_startA + (targetColor.a - _startA) * progress).clamp(0.0, 1.0);
    target.color = Color.from(alpha: a, red: r, green: g, blue: b);
    markWorldDirty();
  }
}

/// Interpolates the 4-float `instanceData` vector of a [MeshComponent] or
/// [ModelComponent] toward `targetData`, notifying any enclosing `World3D` so
/// retained caches refresh.
class InstanceDataEffect3D(
  Vector4 targetData,
  super.controller, {
  super.onComplete,
  super.key,
}) extends Effect3D<Object3D> {
  final Vector4 _targetData = targetData.clone();
  final Vector4 _startData = Vector4.zero();

  Vector4 _resolveInstanceData(Object3D object) {
    if (object is MeshComponent) {
      return object.instanceData;
    }
    if (object is ModelComponent) {
      return object.instanceData;
    }
    throw UnsupportedError(
      'InstanceDataEffect3D only supports MeshComponent or ModelComponent',
    );
  }

  @override
  void onMount() {
    super.onMount();
    _resolveInstanceData(target);
  }

  @override
  void onStart() {
    super.onStart();
    _startData.setFrom(_resolveInstanceData(target));
  }

  @override
  void apply(double progress) {
    final data = _resolveInstanceData(target);
    data.setValues(
      _startData.x + (_targetData.x - _startData.x) * progress,
      _startData.y + (_targetData.y - _startData.y) * progress,
      _startData.z + (_targetData.z - _startData.z) * progress,
      _startData.w + (_targetData.w - _startData.w) * progress,
    );
    markWorldDirty();
  }
}
