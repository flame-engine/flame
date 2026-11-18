import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/texture_info.dart';

/// A set of parameter values that are used to define the metallic-roughness
/// material model from Physically-Based Rendering (PBR) methodology.
class PBRMetallicRoughness({
  required super.root,
  required final Vector4? baseColorFactor,
  required final TextureInfo? baseColorTexture,
  required final double metallicFactor,
  required final double roughnessFactor,
  required final TextureInfo? metallicRoughnessTexture,
}) extends GltfNode {
  PBRMetallicRoughness.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        baseColorFactor: Parser.vector4(root, map, 'baseColorFactor'),
        baseColorTexture: Parser.object(
          root,
          map,
          'baseColorTexture',
          TextureInfo.parse,
        ),
        metallicFactor: Parser.float(map, 'metallicFactor') ?? 1.0,
        roughnessFactor: Parser.float(map, 'roughnessFactor') ?? 1.0,
        metallicRoughnessTexture: Parser.object(
          root,
          map,
          'metallicRoughnessTexture',
          TextureInfo.parse,
        ),
      );

  flame_3d.SpatialMaterial toFlameSpatialMaterial() {
    return flame_3d.SpatialMaterial(
      albedoColor: baseColorFactor?.toColor() ?? const Color(0xFFFFFFFF),
      albedoTexture: baseColorTexture?.toFlameTexture(),
      metallic: metallicFactor,
      roughness: roughnessFactor,
      metallicRoughnessTexture: metallicRoughnessTexture?.toFlameTexture(),
    );
  }
}

extension ToColorVector4 on Vector4 {
  Color toColor() {
    return Color.fromARGB(
      (a.clamp(0.0, 1.0) * 255).round(),
      (r.clamp(0.0, 1.0) * 255).round(),
      (g.clamp(0.0, 1.0) * 255).round(),
      (b.clamp(0.0, 1.0) * 255).round(),
    );
  }
}
