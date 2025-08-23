import 'package:flame_3d/core.dart';
import 'package:flame_3d/resources.dart' as flame_3d;
import 'package:flame_3d/src/parser/gltf/alpha_mode.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/normal_texture_info.dart';
import 'package:flame_3d/src/parser/gltf/occlusion_texture_info.dart';
import 'package:flame_3d/src/parser/gltf/pbr_metallic_roughness.dart';
import 'package:flame_3d/src/parser/gltf/texture_info.dart';

/// The material appearance of a primitive.
class Material extends GltfNode {
  final String? name;

  /// A set of parameter values that are used to define the metallic-roughness
  /// material model from Physically Based Rendering (PBR) methodology.
  /// When undefined, all the default values of `pbrMetallicRoughness` **MUST**
  /// apply.
  final PBRMetallicRoughness? pbrMetallicRoughness;

  /// The tangent space normal texture. The texture encodes RGB components with
  /// linear transfer function.
  /// Each texel represents the XYZ components of a normal vector in tangent
  /// space.
  /// The normal vectors use the convention +X is right and +Y is up. +Z points
  /// toward the viewer.
  /// If a fourth component (A) is present, it **MUST** be ignored.
  /// When undefined, the material does not have a tangent space normal texture.
  final NormalTextureInfo? normalTexture;

  /// The occlusion texture. The occlusion values are linearly sampled from the
  /// R channel.
  /// Higher values indicate areas that receive full indirect lighting and lower
  /// values indicate no indirect lighting.
  /// If other channels are present (GBA), they **MUST** be ignored for
  /// occlusion calculations.
  /// When undefined, the material does not have an occlusion texture.
  final OcclusionTextureInfo? occlusionTexture;

  /// The emissive texture. It controls the color and intensity of the light
  /// being emitted by the material.
  /// This texture contains RGB components encoded with the sRGB transfer
  /// function.
  /// If a fourth component (A) is present, it **MUST** be ignored.
  /// When undefined, the texture **MUST** be sampled as having `1.0` in RGB
  /// components.
  final TextureInfo? emissiveTexture;

  /// The factors for the emissive color of the material. This value defines
  /// linear multipliers for the sampled texels of the emissive texture.
  final Vector3 emissiveFactor;

  /// The material's alpha rendering mode enumeration specifying the
  /// interpretation of the alpha value of the base color.
  final AlphaMode alphaMode;

  /// Specifies whether the material is double sided. When this value is false,
  /// back-face culling is enabled.
  /// When this value is true, back-face culling is disabled and double-sided
  /// lighting is enabled.
  /// The back-face **MUST** have its normals reversed before the lighting
  /// equation is evaluated.
  final bool doubleSided;

  Material({
    required super.root,
    required this.name,
    required this.pbrMetallicRoughness,
    required this.normalTexture,
    required this.occlusionTexture,
    required this.emissiveTexture,
    required this.emissiveFactor,
    required this.alphaMode,
    required this.doubleSided,
  });

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
        doubleSided: Parser.boolean(map, 'doubleSided') ?? false,
      );

  flame_3d.Material? toFlameMaterial() {
    return pbrMetallicRoughness?.toFlameSpatialMaterial();
  }
}
