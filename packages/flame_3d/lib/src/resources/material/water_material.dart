import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template water_material}
/// Animated 4-wave Gerstner GPU water material with scrolling micro-ripples,
/// shallow/deep color gradient, crest foam, Fresnel sky reflection, sun/point
/// specular glints, directional PCF shadow reception, and [FogSettings].
///
/// Works in both `+Y`-up (`upAxis: Vector3(0, 1, 0)`) and `+Z`-up
/// (`upAxis: Vector3(0, 0, 1)`) worlds. Advance [time] each frame to animate.
/// {@endtemplate}
class WaterMaterial({
  var Color shallowColor = const Color(0xFF38BDF8),
  var Color deepColor = const Color(0xFF0F3460),
  var Color foamColor = const Color(0xE6F8FAFC),
  var double time = 0.0,
  var double waveAmplitude = 0.08,
  var double waveFrequency = 1.6,
  var double waveSpeed = 1.8,
  var double steepness = 0.45,
  Vector3? upAxis,
  var double rippleStrength = 0.08,
  var double rippleScale = 0.85,
  var double foamThreshold = 0.68,
  var double fresnelPower = 3.2,
  var double specularStrength = 0.85,
  var double specularPower = 48.0,
  var double opacity = 0.86,

  /// Clip-depth thickness span (`> 0` generates shoreline intersection foam
  /// where opaque scene geometry meets the water surface when
  /// `World3D.depthPrepassEnabled` is active).
  var double shoreFoamDepth = 0.0,
}) extends Material {
  /// {@macro water_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          _bundle,
          slots: [RenderContext3D.cameraMatricesBlock, 'WaterVertex'],
        ),
        fragmentShader: FragmentShader.fromAsset(
          _bundle,
          slots: [
            'WaterMaterial',
            RenderContext3D.stylizedPassBlock,
            RenderContext3D.shadowMapSampler,
            RenderContext3D.depthNormalSampler,
            RenderContext3D.depthNormalBlock,
          ],
        ),
      ) {
    castsShadows = false;
    renderState = opacity < 1.0
        ? RenderState.alphaBlend.copyWith(cullMode: CullMode.backFace)
        : const RenderState(cullMode: CullMode.backFace);
  }

  static const String _bundle =
      'packages/flame_3d/assets/shaders/water_material.shaderbundle';

  /// World up axis perpendicular to the rest water surface.
  Vector3 upAxis = upAxis?.clone() ?? Vector3(0, 1, 0);

  static final Vector4 _waveParams = Vector4.zero();
  static final Vector4 _upSteep = Vector4.zero();
  static final Vector4 _fragParams = Vector4.zero();
  static final Vector4 _fragParams2 = Vector4.zero();
  static final Vector4 _shoreVec = Vector4.zero();

  @override
  void apply(RenderContext context) {
    vertexShader
      ..setVector4(
        'WaterVertex.waveParams',
        _waveParams..setValues(time, waveAmplitude, waveFrequency, waveSpeed),
      )
      ..setVector4(
        'WaterVertex.upAndSteepness',
        _upSteep..setValues(upAxis.x, upAxis.y, upAxis.z, steepness),
      );

    fragmentShader
      ..setColor('WaterMaterial.shallowColor', shallowColor)
      ..setColor('WaterMaterial.deepColor', deepColor)
      ..setColor('WaterMaterial.foamColor', foamColor)
      ..setVector4(
        'WaterMaterial.params',
        _fragParams..setValues(
          time,
          rippleStrength,
          foamThreshold,
          specularPower,
        ),
      )
      ..setVector4(
        'WaterMaterial.params2',
        _fragParams2..setValues(
          fresnelPower,
          specularStrength,
          opacity,
          rippleScale,
        ),
      )
      ..setVector4(
        'WaterMaterial.shoreParams',
        _shoreVec..setValues(shoreFoamDepth, 0, 0, 0),
      );
  }
}
