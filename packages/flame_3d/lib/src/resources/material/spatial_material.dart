import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template spatial_material}
/// Physically-based Cook-Torrance metallic-roughness material supporting full
/// glTF 2.0 maps ([albedoTexture], tangent-free [normalTexture],
/// [metallicRoughnessTexture], [occlusionTexture], [emissiveTexture]),
/// equirectangular [environmentTexture] IBL reflections, UV tiling/offset,
/// directional PCF shadows, [SpotLight]s, [FogSettings], `MASK` [alphaCutoff],
/// `4x4` Bayer [ditherFade], and seamless single-piece translucency.
/// {@endtemplate}
class SpatialMaterial({
  /// Base color multiplier (`rgb` and `a`).
  var Color albedoColor = const Color(0xFFFFFFFF),
  Texture? albedoTexture,
  var double metallic = 0.8,
  var double roughness = 0.6,

  /// Optional tangent-space RGB normal map perturbed via a screen-space
  /// cotangent frame (no vertex tangent attribute required).
  var Texture? normalTexture,

  /// Strength multiplier applied to the XY perturbation of [normalTexture].
  var double normalScale = 1.0,

  /// Optional glTF metallic-roughness map (`G` = roughness, `B` = metallic).
  var Texture? metallicRoughnessTexture,

  /// Optional ambient-occlusion map (`R` channel).
  var Texture? occlusionTexture,

  /// Blend factor `[0..1]` for [occlusionTexture].
  var double occlusionStrength = 1.0,

  /// Emissive color added before tone mapping (`0xFF000000` = no emission).
  var Color emissiveColor = const Color(0xFF000000),

  /// Multiplier on [emissiveColor] and [emissiveTexture].
  var double emissiveStrength = 1.0,

  /// Optional emissive RGB texture multiplied by [emissiveColor].
  var Texture? emissiveTexture,

  /// Optional equirectangular environment reflection map sampled along the
  /// view reflection vector.
  var Texture? environmentTexture,

  /// Reflection strength for [environmentTexture] (`0` when unset).
  var double environmentIntensity = 1.0,

  /// Optional pre-filtered `SH9` diffuse irradiance + specular reflection
  /// probe (`EnvironmentProbe3D`).
  var EnvironmentProbe3D? environmentProbe,

  /// UV scale (`(1, 1)` by default).
  Vector2? uvScale,

  /// UV offset (`(0, 0)` by default).
  Vector2? uvOffset,

  /// Alpha threshold below which fragments are discarded (`0` disables cutout).
  var double alphaCutoff = 0.0,

  /// Reverses back-face normals before shading when `CullMode.none` is used.
  var bool doubleSided = false,

  /// Dissolves opaque draws via a `4x4` Bayer screen-space dither pattern.
  var bool ditherFade = false,

  /// Convenience flag configuring [renderState] for translucent blending (with
  /// [RenderState.singlePieceAlphaBlend] when `singlePieceTranslucent` is
  /// `true`).
  bool translucent = false,
  bool singlePieceTranslucent = false,
}) extends Material {
  /// {@macro spatial_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
          slots: [
            RenderContext3D.cameraMatricesBlock,
            RenderContext3D.jointMatricesBlock,
          ],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
          slots: [
            'albedoTexture',
            'normalTexture',
            'metallicRoughnessTexture',
            'occlusionTexture',
            'emissiveTexture',
            'environmentTexture',
            RenderContext3D.shadowMapSampler,
            'Material',
            RenderContext3D.ambientLightBlock,
            RenderContext3D.lightsBlock,
            RenderContext3D.directionalLightsBlock,
            RenderContext3D.spotLightsBlock,
            RenderContext3D.hemisphereLightBlock,
            RenderContext3D.cameraBlock,
            RenderContext3D.shadowsBlock,
            RenderContext3D.fogBlock,
          ],
        ),
      ) {
    if (doubleSided && !translucent) {
      renderState = RenderState.opaque;
    }
    if (translucent) {
      renderState = singlePieceTranslucent
          ? RenderState.singlePieceAlphaBlend
          : RenderState.alphaBlend;
    }
  }

  /// Base albedo texture multiplied by [albedoColor].
  Texture albedoTexture = albedoTexture ?? Texture.standard;

  /// UV tiling scale.
  Vector2 uvScale = uvScale ?? Vector2.all(1);

  /// UV translation offset.
  Vector2 uvOffset = uvOffset ?? Vector2.zero();

  static final Vector4 _emissiveVec = Vector4.zero();
  static final Vector4 _uvVec = Vector4.zero();
  static final Vector4 _paramsVec = Vector4.zero();
  static final Vector4 _flagsVec = Vector4.zero();
  static final Vector4 _flags2Vec = Vector4.zero();
  static final Vector4 _shScratch = Vector4.zero();

  @override
  void apply(RenderContext context) {
    final normTex = normalTexture;
    final ormTex = metallicRoughnessTexture;
    final occTex = occlusionTexture;
    final emiTex = emissiveTexture;
    final probe = environmentProbe;
    final envTex = environmentTexture ?? probe?.reflectionTexture;
    final premul = renderState.blend == BlendState.premultipliedAlpha;

    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setTexture('normalTexture', normTex ?? Texture.standard)
      ..setTexture('metallicRoughnessTexture', ormTex ?? Texture.standard)
      ..setTexture('occlusionTexture', occTex ?? Texture.standard)
      ..setTexture('emissiveTexture', emiTex ?? Texture.standard)
      ..setTexture('environmentTexture', envTex ?? Texture.standard)
      ..setColor('Material.albedoColor', albedoColor)
      ..setVector4(
        'Material.emissiveColor',
        _emissiveVec..setValues(
          emissiveColor.r * emissiveStrength,
          emissiveColor.g * emissiveStrength,
          emissiveColor.b * emissiveStrength,
          alphaCutoff,
        ),
      )
      ..setVector4(
        'Material.uvTransform',
        _uvVec..setValues(uvScale.x, uvScale.y, uvOffset.x, uvOffset.y),
      )
      ..setVector4(
        'Material.params',
        _paramsVec..setValues(
          metallic,
          roughness,
          normalScale,
          occlusionStrength,
        ),
      )
      ..setVector4(
        'Material.flags',
        _flagsVec..setValues(
          normTex != null ? 1.0 : 0.0,
          ormTex != null ? 1.0 : 0.0,
          occTex != null ? 1.0 : 0.0,
          envTex != null ? environmentIntensity : 0.0,
        ),
      )
      ..setVector4(
        'Material.flags2',
        _flags2Vec..setValues(
          doubleSided ? 1.0 : 0.0,
          ditherFade ? 1.0 : 0.0,
          premul ? 1.0 : 0.0,
          emiTex != null ? 1.0 : 0.0,
        ),
      );

    final matBlock = fragmentShader.block('Material');
    if (probe != null && probe.intensity > 0) {
      for (var i = 0; i < 9; i++) {
        final c = probe.shCoefficients[i];
        matBlock.setVector4(
          'shCoeffs',
          _shScratch..setValues(c.x, c.y, c.z, i == 0 ? probe.intensity : 0.0),
          index: i,
        );
      }
    } else {
      matBlock.setVector4(
        'shCoeffs',
        _shScratch..setZero(),
        index: 0,
      );
    }
  }
}
