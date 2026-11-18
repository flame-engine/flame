import 'dart:ui' show Color;

import 'package:flame_3d/resources.dart';

/// {@template ambient_light}
/// A light that reaches every surface equally, from every direction.
///
/// The first ambient light of a scene is used. A scene with neither an
/// ambient light nor a [HemisphereLight] gets a white ambient light of
/// intensity `0.2`.
/// {@endtemplate}
class AmbientLight({
  super.color = const Color(0xFFFFFFFF),
  super.intensity = 0.2,
}) extends LightSource;
