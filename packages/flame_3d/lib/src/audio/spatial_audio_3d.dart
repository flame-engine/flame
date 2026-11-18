import 'dart:math' as math;

import 'package:flame/components.dart' show Component;
import 'package:flame_3d/camera.dart' show CameraComponent3D, Ray, World3D;
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';

/// Distance-based volume rolloff curve for [SpatialAudioEmitter3D].
enum AudioAttenuationModel3D() {
  /// Clamped OpenAL/WebAudio inverse-distance rolloff:
  /// `minDistance / (minDistance + rolloff * (d - minDistance))`.
  inverseDistance,

  /// Linear gain ramp from `1.0` at `minDistance` to `0.0` at `maxDistance`.
  linear,

  /// Exponential power-law rolloff `(d / minDistance)^(-rolloff)`.
  exponential,
}

/// Evaluated 3D stereo spatial mix parameters ready to feed `flame_audio` or a
/// custom audio backend.
class SpatialMix3D({
  required final double volume,
  required final double pan,
  required final double pitch,
  required final bool occluded,
}) {
  /// Silent neutral mix (`volume: 0`, `pan: 0`, `pitch: 1`, `occluded: false`).
  static final SpatialMix3D silent = SpatialMix3D(
    volume: 0.0,
    pan: 0.0,
    pitch: 1.0,
    occluded: false,
  );
}

/// 3D spatial audio listener tracking a [CameraComponent3D], an arbitrary
/// [Component3D], or its own [Component3D] transform.
class SpatialAudioListener3D({
  this.camera,
  this.target,
  var double speedOfSound = 343.0,
  var double dopplerFactor = 1.0,
  var bool autoComputeVelocity = true,
  Vector3? velocity,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  this : assert(speedOfSound > 0, 'speedOfSound must be positive');

  /// Optional camera whose eye position, forward, up, and right vectors define
  /// the listener ears.
  CameraComponent3D? camera;

  /// Optional [Component3D] tracked when [camera] is `null`.
  Component3D? target;

  /// Listener world velocity (`m/s`) used for Doppler pitch shift.
  final Vector3 velocity = velocity?.clone() ?? Vector3.zero();

  final Vector3 _earPos = Vector3.zero();
  final Vector3 _forward = Vector3(0.0, 0.0, -1.0);
  final Vector3 _up = Vector3(0.0, 1.0, 0.0);
  final Vector3 _right = Vector3(1.0, 0.0, 0.0);
  final Vector3 _prevPos = Vector3.zero();
  bool _hasPrevPos = false;

  /// Current world-space ear position.
  Vector3 get earPosition {
    syncFrame();
    return _earPos;
  }

  /// Current unit forward vector (`-Z` in default right-handed view space).
  Vector3 get forward {
    syncFrame();
    return _forward;
  }

  /// Current unit up vector (`+Y` by default).
  Vector3 get up {
    syncFrame();
    return _up;
  }

  /// Current unit right ear vector (`forward x up`, `+X` by default).
  Vector3 get right {
    syncFrame();
    return _right;
  }

  /// Refreshes [earPosition], [forward], [up], and [right] from [camera],
  /// [target], or this component's own `worldTransformMatrix`.
  void syncFrame() {
    final cam = camera;
    if (cam != null) {
      final inv = cam.inverseViewMatrix.storage;
      // Columns of `inverseViewMatrix`: right (col0), up (col1), backward
      // (col2 = -forward), eyePosition (col3).
      _earPos.setValues(inv[12], inv[13], inv[14]);
      _right.setValues(inv[0], inv[1], inv[2]);
      if (_right.length2 > 1e-12) {
        _right.normalize();
      } else {
        _right.setValues(1.0, 0.0, 0.0);
      }
      _up.setValues(inv[4], inv[5], inv[6]);
      if (_up.length2 > 1e-12) {
        _up.normalize();
      } else {
        _up.setValues(0.0, 1.0, 0.0);
      }
      _forward.setValues(-inv[8], -inv[9], -inv[10]);
      if (_forward.length2 > 1e-12) {
        _forward.normalize();
      } else {
        _forward.setValues(0.0, 0.0, -1.0);
      }
      return;
    }

    final src = target ?? this;
    final m = src.worldTransformMatrix.storage;
    _earPos.setValues(m[12], m[13], m[14]);

    // Right-handed local frame: +X right, +Y up, -Z forward.
    _forward.setValues(-m[8], -m[9], -m[10]);
    if (_forward.length2 > 1e-12) {
      _forward.normalize();
    } else {
      _forward.setValues(0.0, 0.0, -1.0);
    }

    _up.setValues(m[4], m[5], m[6]);
    if (_up.length2 > 1e-12) {
      _up.normalize();
    } else {
      _up.setValues(0.0, 1.0, 0.0);
    }

    _right.setValues(
      _forward.y * _up.z - _forward.z * _up.y,
      _forward.z * _up.x - _forward.x * _up.z,
      _forward.x * _up.y - _forward.y * _up.x,
    );
    if (_right.length2 > 1e-12) {
      _right.normalize();
    } else {
      _right.setValues(1.0, 0.0, 0.0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    syncFrame();
    if (autoComputeVelocity && dt > 1e-6) {
      if (_hasPrevPos) {
        final invDt = 1.0 / dt;
        velocity.setValues(
          (_earPos.x - _prevPos.x) * invDt,
          (_earPos.y - _prevPos.y) * invDt,
          (_earPos.z - _prevPos.z) * invDt,
        );
      }
      _prevPos.setFrom(_earPos);
      _hasPrevPos = true;
    }
  }
}

/// 3D spatial audio emitter attachable to any [Component3D] (including
/// `BoneSocket3D`), computing stereo `pan`, distance rolloff, directional sound
/// cones, raycast wall occlusion via `World3D.raycast`, and Doppler `pitch`.
class SpatialAudioEmitter3D({
  var double baseVolume = 1.0,
  var double minDistance = 1.0,
  var double maxDistance = 50.0,
  var double rolloff = 1.0,
  var AudioAttenuationModel3D attenuationModel =
      AudioAttenuationModel3D.inverseDistance,
  var double innerConeRad = math.pi * 2.0,
  var double outerConeRad = math.pi * 2.0,
  var double outerConeGain = 0.25,
  Vector3? localForward,
  var bool enableOcclusion = false,
  var double occlusionGain = 0.35,
  this.occlusionFilter,
  var double dopplerFactor = 1.0,
  var double minPitch = 0.5,
  var double maxPitch = 2.0,
  var bool autoComputeVelocity = true,
  Vector3? velocity,
  this.listener,
  this.onMixChanged,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Component3D {
  this
    : assert(minDistance > 0, 'minDistance must be positive'),
      assert(maxDistance >= minDistance, 'maxDistance must be >= minDistance'),
      assert(innerConeRad <= outerConeRad, 'innerConeRad <= outerConeRad');

  /// Local emission axis for directional cones (`(0, 0, -1)` by default).
  final Vector3 localForward =
      (localForward?.clone() ?? Vector3(0.0, 0.0, -1.0))..normalize();

  /// Emitter world velocity (`m/s`) used for Doppler pitch shift.
  final Vector3 velocity = velocity?.clone() ?? Vector3.zero();

  /// Optional filter choosing which [Object3D]s block line-of-sight when
  /// [enableOcclusion] is `true`.
  bool Function(Object3D object)? occlusionFilter;

  /// Optional explicit listener; when `null`, discovers the first mounted
  /// [SpatialAudioListener3D] in the enclosing [World3D].
  SpatialAudioListener3D? listener;

  /// Optional sink invoked with the evaluated [SpatialMix3D] each frame.
  void Function(SpatialMix3D mix)? onMixChanged;

  SpatialMix3D _lastMix = SpatialMix3D.silent;

  /// Most recently evaluated [SpatialMix3D].
  SpatialMix3D get lastMix => _lastMix;

  final Vector3 _emitterPos = Vector3.zero();
  final Vector3 _prevPos = Vector3.zero();
  final Vector3 _worldFwd = Vector3.zero();
  final Vector3 _toEar = Vector3.zero();
  final Ray _occlusionRay = Ray();
  bool _hasPrevPos = false;

  @override
  void update(double dt) {
    super.update(dt);
    final m = worldTransformMatrix.storage;
    _emitterPos.setValues(m[12], m[13], m[14]);

    if (autoComputeVelocity && dt > 1e-6) {
      if (_hasPrevPos) {
        final invDt = 1.0 / dt;
        velocity.setValues(
          (_emitterPos.x - _prevPos.x) * invDt,
          (_emitterPos.y - _prevPos.y) * invDt,
          (_emitterPos.z - _prevPos.z) * invDt,
        );
      }
      _prevPos.setFrom(_emitterPos);
      _hasPrevPos = true;
    }

    final activeListener = listener ?? _findListenerInWorld();
    if (activeListener != null) {
      final mix = evaluateMix(activeListener, world: _findEnclosingWorld());
      onMixChanged?.call(mix);
    }
  }

  /// Evaluates and caches the [SpatialMix3D] perceived by [activeListener].
  SpatialMix3D evaluateMix(
    SpatialAudioListener3D activeListener, {
    World3D? world,
  }) {
    activeListener.syncFrame();
    final earPos = activeListener.earPosition;
    final m = worldTransformMatrix.storage;
    _emitterPos.setValues(m[12], m[13], m[14]);

    // Vector from listener ear to emitter (`emitterPos - earPos`) for panning.
    final dx = _emitterPos.x - earPos.x;
    final dy = _emitterPos.y - earPos.y;
    final dz = _emitterPos.z - earPos.z;
    final dist = math.sqrt(dx * dx + dy * dy + dz * dz);

    // 1. Distance attenuation.
    final distGain = _computeDistanceGain(dist);

    // 2. Stereo pan in `[-1..1]` (`-1` left, `+1` right).
    var pan = 0.0;
    if (dist > 1e-6) {
      final invDist = 1.0 / dist;
      final right = activeListener.right;
      pan = ((dx * right.x + dy * right.y + dz * right.z) * invDist).clamp(
        -1.0,
        1.0,
      );
    }

    // 3. Directional sound cone gain (`innerConeRad` & `outerConeRad` are full
    // cone angles in `[0..2*pi]`).
    var coneGain = 1.0;
    if (dist > 1e-6 && innerConeRad < math.pi * 2.0 - 1e-6) {
      _worldFwd.setValues(
        m[0] * localForward.x + m[4] * localForward.y + m[8] * localForward.z,
        m[1] * localForward.x + m[5] * localForward.y + m[9] * localForward.z,
        m[2] * localForward.x + m[6] * localForward.y + m[10] * localForward.z,
      );
      final fwdLen = _worldFwd.length;
      if (fwdLen > 1e-12) {
        _worldFwd.scale(1.0 / fwdLen);
        final invDist = 1.0 / dist;
        // Unit vector from emitter toward listener ear (`-d / dist`).
        final cosAngle =
            ((-_worldFwd.x * dx - _worldFwd.y * dy - _worldFwd.z * dz) *
                    invDist)
                .clamp(-1.0, 1.0);
        final halfAngle = math.acos(cosAngle);
        final innerHalf = 0.5 * innerConeRad;
        final outerHalf = 0.5 * outerConeRad;
        if (halfAngle >= outerHalf) {
          coneGain = outerConeGain;
        } else if (halfAngle > innerHalf && outerHalf > innerHalf + 1e-9) {
          final t = (halfAngle - innerHalf) / (outerHalf - innerHalf);
          coneGain = 1.0 + (outerConeGain - 1.0) * t;
        }
      }
    }

    // 4. Optional raycast wall occlusion via `World3D.raycast`.
    var occluded = false;
    final resolvedWorld = world ?? _findEnclosingWorld();
    if (enableOcclusion && resolvedWorld != null && dist > 2e-3) {
      final invDist = 1.0 / dist;
      _toEar.setValues(-dx * invDist, -dy * invDist, -dz * invDist);
      _occlusionRay.origin.setValues(
        _emitterPos.x + _toEar.x * 1e-3,
        _emitterPos.y + _toEar.y * 1e-3,
        _emitterPos.z + _toEar.z * 1e-3,
      );
      _occlusionRay.direction.setFrom(_toEar);

      final hit = resolvedWorld.raycast(
        _occlusionRay,
        maxDistance: dist - 2e-3,
        filter: (obj) {
          if (_isSelfOrAncestor(obj, this) ||
              _isSelfOrAncestor(obj, activeListener) ||
              (activeListener.target != null &&
                  _isSelfOrAncestor(obj, activeListener.target!))) {
            return false;
          }
          return occlusionFilter == null || occlusionFilter!(obj);
        },
      );
      occluded = hit != null;
    }

    // 5. Acoustic 3D Doppler pitch shift.
    var pitch = 1.0;
    final kDoppler = dopplerFactor * activeListener.dopplerFactor;
    if (dist > 1e-6 && kDoppler > 0.0) {
      final invDist = 1.0 / dist;
      // Unit vector `u` from emitter toward listener ear.
      final ux = -dx * invDist;
      final uy = -dy * invDist;
      final uz = -dz * invDist;
      final vSource = velocity.x * ux + velocity.y * uy + velocity.z * uz;
      final vListener =
          activeListener.velocity.x * ux +
          activeListener.velocity.y * uy +
          activeListener.velocity.z * uz;
      final c = activeListener.speedOfSound;
      final maxSpeed = 0.9 * c / kDoppler;
      final vsClamped = vSource.clamp(-maxSpeed, maxSpeed);
      final vlClamped = vListener.clamp(-maxSpeed, maxSpeed);
      pitch = ((c - kDoppler * vlClamped) / (c - kDoppler * vsClamped)).clamp(
        minPitch,
        maxPitch,
      );
    }

    final occMult = occluded ? occlusionGain : 1.0;
    final volume = (baseVolume * distGain * coneGain * occMult)
        .clamp(0.0, math.max(1.0, baseVolume))
        .toDouble();

    return _lastMix = SpatialMix3D(
      volume: volume,
      pan: pan,
      pitch: pitch,
      occluded: occluded,
    );
  }

  double _computeDistanceGain(double dist) {
    switch (attenuationModel) {
      case AudioAttenuationModel3D.inverseDistance:
        final d = dist.clamp(minDistance, maxDistance);
        final denom = minDistance + rolloff * (d - minDistance);
        return denom > 1e-9 ? (minDistance / denom).clamp(0.0, 1.0) : 1.0;
      case AudioAttenuationModel3D.linear:
        final d = dist.clamp(minDistance, maxDistance);
        final span = maxDistance - minDistance;
        if (span <= 1e-9) {
          return dist <= minDistance ? 1.0 : 0.0;
        }
        return (1.0 - rolloff * (d - minDistance) / span).clamp(0.0, 1.0);
      case AudioAttenuationModel3D.exponential:
        final d = dist.clamp(minDistance, maxDistance);
        return math.pow(d / minDistance, -rolloff).clamp(0.0, 1.0).toDouble();
    }
  }

  World3D? _findEnclosingWorld() {
    for (final anc in ancestors()) {
      if (anc is World3D) {
        return anc;
      }
    }
    return null;
  }

  SpatialAudioListener3D? _findListenerInWorld() {
    final w = _findEnclosingWorld();
    if (w == null) {
      return null;
    }
    SpatialAudioListener3D? found;
    void visit(Component c) {
      if (found != null) {
        return;
      }
      if (c is SpatialAudioListener3D) {
        found = c;
        return;
      }
      for (final child in c.children) {
        visit(child);
      }
    }

    visit(w);
    return found;
  }

  static bool _isSelfOrAncestor(Object3D candidate, Component3D ref) {
    if (identical(candidate, ref)) {
      return true;
    }
    for (final anc in ref.ancestors()) {
      if (identical(anc, candidate)) {
        return true;
      }
    }
    return false;
  }
}
