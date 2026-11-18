import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart' as flame_gfx;
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/alpha_mode.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/normal_texture_info.dart';
import 'package:flame_3d/src/parser/gltf/occlusion_texture_info.dart';
import 'package:flame_3d/src/parser/gltf/pbr_metallic_roughness.dart';
import 'package:flame_3d/src/parser/gltf/texture_info.dart';

/// The material appearance of a primitive.
class Material({
  required super.root,
  required final String? name,
  required final PBRMetallicRoughness? pbrMetallicRoughness,
  required final NormalTextureInfo? normalTexture,
  required final OcclusionTextureInfo? occlusionTexture,
  required final TextureInfo? emissiveTexture,
  required final Vector3 emissiveFactor,
  required final AlphaMode alphaMode,
  required final double alphaCutoff,
  required final bool doubleSided,
  final Map<String, Object?>? extensions,
  final Object? extras,
}) extends GltfNode {
  Material.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        name: Parser.string(map, 'name'),
        pbrMetallicRoughness: Parser.object(
          root,
          map,
          'pbrMetallicRoughness',
          PBRMetallicRoughness.parse,
        ),
        normalTexture: Parser.object(
          root,
          map,
          'normalTexture',
          NormalTextureInfo.parse,
        ),
        occlusionTexture: Parser.object(
          root,
          map,
          'occlusionTexture',
          OcclusionTextureInfo.parse,
        ),
        emissiveTexture: Parser.object(
          root,
          map,
          'emissiveTexture',
          TextureInfo.parse,
        ),
        emissiveFactor:
            Parser.vector3(root, map, 'emissiveFactor') ?? Vector3.all(0),
        alphaMode: AlphaMode.parse(map, 'alphaMode') ?? AlphaMode.opaque,
        alphaCutoff: Parser.float(map, 'alphaCutoff') ?? 0.5,
        doubleSided: Parser.boolean(map, 'doubleSided') ?? false,
        extensions: Parser.extensions(map),
        extras: Parser.extras(map),
      );

  /// Whether `KHR_materials_unlit` is enabled on this material.
  bool get isUnlit => extensions?['KHR_materials_unlit'] != null;

  /// Emissive multiplier from `KHR_materials_emissive_strength` (`1.0` by
  /// default).
  double get emissiveStrength {
    final ext = extensions?['KHR_materials_emissive_strength'];
    if (ext is Map<String, Object?>) {
      return Parser.float(ext, 'emissiveStrength') ?? 1.0;
    }
    return 1.0;
  }

  flame_3d.Material toFlameMaterial() {
    final pbr = pbrMetallicRoughness;
    final cullMode = doubleSided
        ? flame_gfx.CullMode.none
        : flame_gfx.CullMode.backFace;

    if (isUnlit) {
      final unlit = flame_3d.UnlitMaterial(
        albedoColor: pbr?.baseColorFactor?.toColor() ?? const Color(0xFFFFFFFF),
        albedoTexture: pbr?.baseColorTexture?.toFlameTexture(),
      );
      unlit.renderState = switch (alphaMode) {
        AlphaMode.opaque || AlphaMode.mask => flame_gfx.RenderState.opaque,
        AlphaMode.blend => flame_gfx.RenderState.alphaBlend.copyWith(
          cullMode: cullMode,
        ),
      };
      return unlit;
    }

    final emissive = Color.fromARGB(
      255,
      (emissiveFactor.x.clamp(0.0, 1.0) * 255).round(),
      (emissiveFactor.y.clamp(0.0, 1.0) * 255).round(),
      (emissiveFactor.z.clamp(0.0, 1.0) * 255).round(),
    );
    final translucent = alphaMode == AlphaMode.blend;
    final cutoff = alphaMode == AlphaMode.mask ? alphaCutoff : 0.0;
    final uvTransform = pbr?.baseColorTexture?.textureTransform;

    final mat = flame_3d.SpatialMaterial(
      albedoColor: pbr?.baseColorFactor?.toColor() ?? const Color(0xFFFFFFFF),
      albedoTexture: pbr?.baseColorTexture?.toFlameTexture(),
      metallic: pbr?.metallicFactor ?? 1.0,
      roughness: pbr?.roughnessFactor ?? 1.0,
      metallicRoughnessTexture: pbr?.metallicRoughnessTexture?.toFlameTexture(),
      normalTexture: normalTexture?.toFlameTexture(),
      normalScale: normalTexture?.scale ?? 1.0,
      occlusionTexture: occlusionTexture?.toFlameTexture(),
      occlusionStrength: occlusionTexture?.strength ?? 1.0,
      emissiveTexture: emissiveTexture?.toFlameTexture(),
      emissiveColor: emissive,
      emissiveStrength: emissiveStrength,
      uvOffset: uvTransform?.offset.clone(),
      uvScale: uvTransform?.scale.clone(),
      alphaCutoff: cutoff,
      doubleSided: doubleSided,
      translucent: translucent,
    );
    mat.renderState = mat.renderState.copyWith(cullMode: cullMode);
    return mat;
  }
}
