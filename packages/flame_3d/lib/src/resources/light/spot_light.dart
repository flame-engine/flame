import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template spot_light}
/// A cone-shaped light source that shines from its position along [direction]
/// (or along the `-Z` axis of its component's world transform when [direction]
/// is `null`).
///
/// Surfaces inside [innerConeAngle] (half-angle, in radians) receive full
/// angular intensity; intensity falls off smoothly to zero at [outerConeAngle].
/// Distance attenuation matches [PointLight]: smooth `(1 - d / range)²` when
/// [range] is positive, or inverse-square `1 / d²` otherwise.
///
/// Up to `RenderContext3D.maxSpotLights` (`4`) spot lights are shaded per pass;
/// when a scene contains more, the active ones nearest to the camera are
/// selected automatically.
/// {@endtemplate}
class SpotLight({
  super.color = const Color(0xFFFFFFFF),
  super.intensity = 1.0,

  /// Optional world-space direction the cone points towards (need not be
  /// normalized). When `null`, the `-Z` axis of the light's transform is used.
  var Vector3? direction,

  /// Inner half-angle of the cone, in radians, within which angular falloff is
  /// `1.0`.
  var double innerConeAngle = math.pi / 8,

  /// Outer half-angle of the cone, in radians, at which light reaches `0.0`.
  var double outerConeAngle = math.pi / 4,

  /// Maximum reach of the light, or `null` (or `<= 0`) for inverse-square
  /// falloff.
  var double? range,

  /// Specular highlight multiplier (`0` = diffuse only, `1` = full specular).
  var double specular = 1.0,

  /// Optional perspective shadow-map settings for this spotlight cone.
  var ShadowSettings? shadows,
}) extends LightSource;
