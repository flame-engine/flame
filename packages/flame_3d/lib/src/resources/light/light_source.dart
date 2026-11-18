import 'dart:ui' show Color;

import 'package:flame_3d/resources.dart';

/// {@template light_source}
/// Describes the properties of a light source: its [color] and [intensity].
///
/// The kinds of light sources are [AmbientLight], [HemisphereLight],
/// [DirectionalLight] and [PointLight]. Their values may be changed at any
/// time: the lights of a scene are read once per render pass.
/// {@endtemplate}
abstract class LightSource({
  /// The color of the light. Its alpha is ignored.
  required var Color color,

  /// The strength of the light, multiplying its [color].
  required var double intensity,
});
