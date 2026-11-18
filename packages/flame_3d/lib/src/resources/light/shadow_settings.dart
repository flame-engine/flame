import 'dart:ui' show Color;

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';

/// {@template shadow_settings}
/// How a [DirectionalLight] casts shadows: the resolution of its shadow map,
/// the part of the scene the map covers, how shadows look, and the biases
/// that keep surfaces from shadowing themselves.
///
/// Give a directional light settings to make it cast shadows:
///
/// ```dart
/// LightComponent.directional(
///   direction: Vector3(-0.4, -1, -0.3),
///   shadows: ShadowSettings(
///     strength: 0.8,
///     color: const Color(0xFF34406A), // cool, tinted shadows
///   ),
/// );
/// ```
///
/// Before the main pass of a scene, the objects that cast shadows (see
/// `Object3D.castsShadows` and [Material.castsShadows]) are rendered from the
/// light into the shadow map: the depth seen from the light, through an
/// orthographic projection fitted to [fit]. Materials that receive shadows
/// (`StylizedMaterial`, `ShadowCatcherMaterial`) compare the depth of their
/// fragments with it. Shadows take away the light's own light: where a
/// surface is shadowed, the direct light of the shadowing light is multiplied
/// by `mix(white, color, strength)`, and ambient and hemisphere light stay.
///
/// Only the first directional light of a scene with settings casts shadows.
/// The settings are read once per frame and may be changed at any time.
/// {@endtemplate}
class ShadowSettings({
  /// The width and height of the shadow map, in texels: more is sharper and
  /// costs more memory and fill rate. 1024 suits phones; a map takes 4 bytes
  /// per texel.
  int resolution = 1024,

  /// The part of the scene the shadow map covers.
  var ShadowFit fit = ShadowFit.view,

  /// The region that receives shadows, in world space, instead of the bounds
  /// of the whole scene: see [ShadowFit]. Casters outside it still cast
  /// shadows into it.
  var Aabb3? bounds,

  /// With [ShadowFit.view], the farthest distance from the camera, along the
  /// direction it looks in, that receives shadows; `null` for no limit
  /// besides the bounds of the scene. Limiting it sharpens the shadows of a
  /// perspective camera that sees far.
  var double? maxDistance,

  /// How much of the light the shadows take away, from `0` (shadows are
  /// invisible) to `1` (as much as [color] says).
  var double strength = 1.0,

  /// The color the shadowed light is multiplied by at full [strength]: black
  /// (the default) takes it all away, and a color lets some of each channel
  /// through, which tints the shadows with it rather than darkening them.
  var Color color = const Color(0xFF000000),

  /// How soft the edges of the shadows are: the radius of the filter, in
  /// texels, from `0` (a 2 by 2 bilinear filter, 4 samples) to `3`. The
  /// default `1` blends a 3 by 3 texel area (16 samples).
  int softness = 1,

  /// How far a receiving surface is pushed towards the light before it is
  /// compared with the shadow map, in texels of the map: it keeps surfaces
  /// facing the light from shadowing themselves (shadow acne). Too much
  /// detaches shadows from the objects that cast them.
  var double depthBias = 1.0,

  /// How far, beyond what the filter of [softness] needs, a receiving
  /// surface is pushed along its normal before it is compared with the
  /// shadow map, in texels of the map, in proportion to the sine of the angle
  /// between the normal and the light: it keeps surfaces lit at grazing
  /// angles, and curved ones, from shadowing themselves.
  var double normalBias = 0.5,

  /// How depths are stored in the shadow map.
  var ShadowMapEncoding encoding = ShadowMapEncoding.auto,

  /// Whether the shadow map is kept aligned with its texels as the camera
  /// moves, so that the edges of the shadows stay still instead of
  /// shimmering. Only turn it off to compare.
  var bool stabilize = true,

  /// Whether the shadow pass is skipped on frames where the light direction,
  /// shadow settings, fitted shadow projection, and shadow-casting scene
  /// geometry have not changed since the previous shadow map was rendered.
  var bool cacheWhenStatic = false,

  /// Number of directional shadow cascades (`1` single map, or `2` near + far
  /// side-by-side shadow atlas).
  int cascades = 1,

  /// Fraction `(0..1)` of `maxDistance` (or scene span) covered by Cascade `0`
  /// when [cascades] is `2`.
  var double cascadeSplitRatio = 0.28,
}) {
  /// {@macro shadow_settings}
  this {
    this.resolution = resolution;
    this.softness = softness;
    this.cascades = cascades;
  }

  /// The width and height of the shadow map, in texels, from 16 to 8192.
  int get resolution => _resolution;
  set resolution(int value) {
    if (value < 16 || value > 8192) {
      throw ArgumentError.value(value, 'resolution', 'Must be 16 to 8192');
    }
    _resolution = value;
  }

  int _resolution = 1024;

  /// The radius of the filter that softens the edges of the shadows, in
  /// texels, from `0` to [maxSoftness].
  int get softness => _softness;
  set softness(int value) {
    if (value < 0 || value > maxSoftness) {
      throw ArgumentError.value(value, 'softness', 'Must be 0 to $maxSoftness');
    }
    _softness = value;
  }

  int _softness = 1;

  /// Number of directional shadow cascades (`1` or `2`).
  int get cascades => _cascades;
  set cascades(int value) {
    if (value < 1 || value > 2) {
      throw ArgumentError.value(value, 'cascades', 'Must be 1 or 2');
    }
    _cascades = value;
  }

  int _cascades = 1;

  /// The largest [softness].
  static const int maxSoftness = 3;
}

/// The part of a scene a [ShadowSettings]'s shadow map covers.
///
/// Both fit the shadow map to the region that receives shadows (the bounds
/// of the scene, or [ShadowSettings.bounds]), and stretch it towards the
/// light over the whole scene, so that every object between the light and
/// that region casts its shadow into it.
enum ShadowFit() {
  /// The part of the region the camera sees: the shadows are as sharp as the
  /// map allows, and the map follows the camera, aligned with its texels so
  /// that the shadows do not shimmer.
  view,

  /// The whole region, whatever the camera sees: the map only changes when
  /// the region does, which suits small scenes seen whole, and scenes whose
  /// camera moves a lot.
  scene,
}

/// How a shadow map stores depths.
enum ShadowMapEncoding() {
  /// [float32] where the GPU can render into 32-bit float textures (Metal and
  /// Vulkan), [rgba8] elsewhere (OpenGL ES).
  auto,

  /// One 32-bit float per texel.
  float32,

  /// 24 bits of depth packed into the red, green and blue channels of an
  /// 8-bit RGBA texel, which every GPU can render into.
  rgba8,
}
