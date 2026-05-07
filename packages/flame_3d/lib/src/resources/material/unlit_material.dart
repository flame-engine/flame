import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template unlit_material}
/// A material that renders textures without any lighting calculations.
///
/// Unlike [SpatialMaterial], this material outputs the texture color multiplied
/// by [albedoColor] directly, with no PBR shading, tone mapping, or gamma
/// correction. This makes it ideal for:
///
/// - 2D canvas content rendered onto 3D surfaces
/// - UI panels and HUD elements in 3D space
/// - Emissive/self-lit surfaces
/// - Skybox and debug rendering
/// {@endtemplate}
class UnlitMaterial extends Material {
  /// {@macro unlit_material}
  UnlitMaterial({
    this.albedoColor = const Color(0xFFFFFFFF),
    Texture? albedoTexture,
  }) : albedoTexture = albedoTexture ?? Texture.standard,
       super(
         vertexShader: VertexShader.fromAsset(
           'packages/flame_3d/assets/shaders/unlit_material.shaderbundle',
           slots: ['VertexInfo'],
         ),
         fragmentShader: FragmentShader.fromAsset(
           'packages/flame_3d/assets/shaders/unlit_material.shaderbundle',
           slots: ['albedoTexture', 'Material'],
         ),
       );

  /// The material's base color, multiplied with [albedoTexture].
  Color albedoColor;

  /// The texture to render. Multiplied by [albedoColor].
  Texture albedoTexture;

  @override
  void apply(covariant RenderContext3D context) {
    vertexShader
      ..setMatrix4('VertexInfo.model', context.model)
      ..setMatrix4('VertexInfo.view', context.view)
      ..setMatrix4('VertexInfo.projection', context.projection);

    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setColor('Material.albedoColor', albedoColor);
  }
}
