import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template unlit_material}
/// A material that renders textures without any lighting calculations.
///
/// Unlike [SpatialMaterial], this material outputs the texture color multiplied
/// by [albedoColor], by the vertex color and by the per-instance color
/// directly, with no PBR shading, tone mapping, or gamma correction. This makes
/// it ideal for:
///
/// - 2D canvas content rendered onto 3D surfaces
/// - UI panels and HUD elements in 3D space
/// - Emissive/self-lit surfaces
/// - Sky boxes and debug rendering
///
/// Its output may be translucent, so by default it blends with premultiplied
/// alpha and is drawn as translucent (after the opaque draws, back to front,
/// never batched) while still writing depth. Set [renderState] to
/// [RenderState.opaque] for opaque content, so that it is batched.
/// {@endtemplate}
class UnlitMaterial({
  /// The material's base color, multiplied with [albedoTexture].
  var Color albedoColor = const Color(0xFFFFFFFF),
  Texture? albedoTexture,
}) extends Material {
  /// {@macro unlit_material}
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'packages/flame_3d/assets/shaders/unlit_material.shaderbundle',
          slots: [
            RenderContext3D.cameraMatricesBlock,
            RenderContext3D.jointMatricesBlock,
          ],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'packages/flame_3d/assets/shaders/unlit_material.shaderbundle',
          slots: ['albedoTexture', 'Material'],
        ),
      ) {
    renderState = const RenderState(blend: BlendState.premultipliedAlpha);
  }

  /// The texture to render. Multiplied by [albedoColor].
  Texture albedoTexture = albedoTexture ?? Texture.standard;

  @override
  void apply(RenderContext context) {
    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setColor('Material.albedoColor', albedoColor);
  }
}
