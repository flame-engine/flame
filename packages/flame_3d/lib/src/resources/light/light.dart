import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template light}
/// A [Resource] that represents a light source that is positioned in the scene
/// and changes how other objects are rendered.
///
/// This class isn't a true resource, it does not upload it self to the GPU.
/// Instead, it is used to modify how other resources are uploaded.
///
/// {@endtemplate}
class Light({
  /// The position of the light in world space, used by point lights.
  required final Vector3 position,

  /// What kind of light this is, and its color and intensity.
  required final LightSource source,

  /// The world transform of the light, whose rotation orients a
  /// [DirectionalLight] without an explicit direction, see [direction].
  ///
  /// It is read when the lights are written, once per render pass, so it may
  /// be a matrix that is updated in place.
  final Matrix4? transform,

  /// 32-bit layer bitmask controlling which camera passes receive this light.
  var int lightMask = 0xFFFFFFFF,
}) extends Resource<void> {
  @override
  void createResource() {}

  /// The unit direction, in world space, the light travels in, written into
  /// [out] (or a new vector).
  ///
  /// It is the [DirectionalLight.direction] of the [source] when it has one,
  /// else the -Z axis of [transform] (the way the light faces), else straight
  /// down.
  Vector3 direction([Vector3? out]) {
    final result = out ?? Vector3.zero();
    final source = this.source;
    final explicit = switch (source) {
      DirectionalLight() => source.direction,
      SpotLight() => source.direction,
      _ => null,
    };
    final transform = this.transform;
    if (explicit != null) {
      result.setFrom(explicit);
    } else if (transform != null) {
      final m = transform.storage;
      result.setValues(-m[8], -m[9], -m[10]);
    } else {
      result.setValues(0, -1, 0);
    }
    final length = result.length;
    if (length > 0) {
      result.scale(1 / length);
    } else {
      result.setValues(0, -1, 0);
    }
    return result;
  }
}
