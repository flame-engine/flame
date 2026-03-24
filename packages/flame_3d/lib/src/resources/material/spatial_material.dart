import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

class SpatialMaterial extends Material {
  SpatialMaterial({
    this.albedoColor = const Color(0xFFFFFFFF),
    Texture? albedoTexture,
    this.metallic = 0.8,
    this.roughness = 0.6,
  }) : albedoTexture = albedoTexture ?? Texture.standard,
       super(
         vertexShader: Shader.vertex(
           asset:
               'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: [
             UniformSlot.value('VertexInfo'),
             UniformSlot.value('JointMatrices'),
           ],
         ),
         fragmentShader: Shader.fragment(
           asset:
               'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: [
             UniformSlot.sampler('albedoTexture'),
             UniformSlot.value('Material'),
             ...LightingInfo.shaderSlots,
             UniformSlot.value('Camera'),
           ],
         ),
       );

  /// The material's base color.
  Color albedoColor;

  /// The texture that will be multiplied by [albedoColor].
  Texture albedoTexture;

  double metallic;

  double roughness;

  @override
  void apply(covariant RenderContext3D context) {
    _bindVertexInfo(context);
    _bindJointMatrices(context);
    _bindMaterial(context);
    _bindCamera(context);
  }

  void _bindVertexInfo(RenderContext3D context) {
    vertexShader
      ..setMatrix4('VertexInfo.model', context.model)
      ..setMatrix4('VertexInfo.view', context.view)
      ..setMatrix4('VertexInfo.projection', context.projection);
  }

  void _bindJointMatrices(RenderContext3D context) {
    final jointTransforms = context.jointsInfo.jointTransforms;
    if (jointTransforms.length > _maxJoints) {
      throw Exception(
        'At most $_maxJoints joints per surface are supported;'
        ' found ${jointTransforms.length}',
      );
    }
    for (final (index, transform) in jointTransforms.indexed) {
      vertexShader.setMatrix4('JointMatrices.joints[$index]', transform);
    }
  }

  void _bindMaterial(RenderContext3D context) {
    context.lightingInfo.apply(fragmentShader);
    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setColor('Material.albedoColor', albedoColor)
      ..setFloat('Material.metallic', metallic)
      ..setFloat('Material.roughness', roughness);
  }

  void _bindCamera(RenderContext3D context) {
    fragmentShader.setVector3('Camera.position', context.cameraPosition);
  }

  static const _maxJoints = 16;
}
