import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';

/// {@template fog_settings}
/// Atmospheric distance and height fog applied to a `World3D` scene.
///
/// Assign [FogSettings] to `World3D.fog` to blend distant or low-lying
/// geometry smoothly towards [color]:
///
/// ```dart
/// world.fog = FogSettings(
///   color: const Color(0xFFC8D8E8),
///   start: 12,
///   end: 48,
///   heightFalloff: 0.15,
///   baseHeight: 0,
/// );
/// ```
///
/// When [density] is `0` (the default), distance fog grows linearly from `0`
/// at [start] units from the camera to `1` at [end] units. When [density] is
/// positive, distance fog follows an exponential curve
/// `1 - exp(-density * max(0, distance - start))`.
///
/// When [heightFalloff] is positive, fog is modulated by elevation along [up]
/// above [baseHeight] (`exp(-heightFalloff * max(0, elevation - baseHeight))`),
/// keeping higher peaks clear while valleys and water stay misty. The final
/// blend factor is clamped to [maxOpacity].
/// {@endtemplate}
class FogSettings({
  /// The color that fogged surfaces blend towards.
  var Color color = const Color(0xFFB8C8DC),

  /// Distance from the camera where fog begins (`>= 0`).
  var double start = 10.0,

  /// Distance from the camera where linear fog reaches full strength
  /// (used when [density] is `0`).
  var double end = 60.0,

  /// Exponential fog density (`0` uses linear fog between [start] and [end]).
  var double density = 0.0,

  /// Exponential falloff rate along [up] above [baseHeight] (`0` disables
  /// height attenuation).
  var double heightFalloff = 0.0,

  /// World-space elevation along [up] below which height fog is at full
  /// strength.
  var double baseHeight = 0.0,

  /// Maximum fog opacity in `[0, 1]`. Values below `1` keep distant
  /// silhouettes subtly visible.
  var double maxOpacity = 1.0,

  /// World-space up direction used for height fog (defaults to `(0, 1, 0)`).
  Vector3? up,
}) {
  /// World-space up axis for height fog.
  final Vector3 up = up?.clone() ?? Vector3(0, 1, 0);
}
