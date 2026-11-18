import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template directional_light}
/// A light infinitely far away, whose rays are parallel, like the sun.
///
/// It lights a surface by `max(0, n·l) * intensity * color`, where `l` points
/// towards the light, whatever the surface's position.
///
/// The direction the light travels in is [direction] when it is set,
/// otherwise the way the [Light] holding it faces (see [Light.direction]):
/// for a `LightComponent`, the -Z axis of its world rotation.
///
/// At most `RenderContext3D.maxDirectionalLights` directional lights are used
/// per scene.
///
/// With [shadows], it casts shadows: see [ShadowSettings]. Only the first
/// directional light of a scene with shadows casts them.
/// {@endtemplate}
class DirectionalLight({
  super.color = const Color(0xFFFFFFFF),
  super.intensity = 1.0,

  /// The direction the light travels in, in world space (for a sun high in
  /// the sky, pointing down). It need not be normalized. When `null`, the
  /// light's transform orients it.
  var Vector3? direction,

  /// How strongly the light makes specular highlights, from `0` (none) to `1`
  /// (fully).
  var double specular = 1.0,

  /// How the light casts shadows, or `null` (the default) when it casts none.
  var ShadowSettings? shadows,
}) extends LightSource;
