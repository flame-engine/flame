import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

class SpatialMaterial extends Material {
  SpatialMaterial({
    Texture? albedoTexture,
    Color albedoColor = const Color(0xFFFFFFFF),
    this.metallic = 0.8,
    this.roughness = 0.6,
  }) : albedoTexture = albedoTexture ?? Texture.standard,
       super(
         vertexShader: Shader.vertex(
           asset:
               'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: [
             UniformSlot.value('VertexInfo', {
               'model',
               'view',
               'projection',
             }),
             UniformSlot.value(
               'JointMatrices',
               List.generate(_maxJoints, (index) => 'joint$index').toSet(),
             ),
           ],
         ),
         fragmentShader: Shader.fragment(
           asset:
               'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: [
             UniformSlot.sampler('albedoTexture'),
             UniformSlot.value('Material', {
               'albedoColor',
               'metallic',
               'roughness',
             }),
             ...LightingInfo.shaderSlots,
             UniformSlot.value('Camera', {'position'}),
           ],
         ),
       ) {
    this.albedoColor = albedoColor;
  }

  /// The material's base color.
  Color get albedoColor => _albedoColor;
  set albedoColor(Color color) {
    _albedoColor = color;
    _albedoCache.copyFromArray(color.storage);
  }

  late Color _albedoColor;
  final Vector3 _albedoCache = Vector3.zero();

  /// The texture that will be multiplied by [albedoColor].
  Texture albedoTexture;

  double metallic;

  double roughness;

  @override
  void bind(GraphicsDevice device) {
    _bindVertexInfo(device);
    _bindJointMatrices(device);
    _bindMaterial(device);
    _bindCamera(device);
  }

  void _bindVertexInfo(GraphicsDevice device) {
    vertexShader
      ..setMatrix4('VertexInfo.model', device.model)
      ..setMatrix4('VertexInfo.view', device.view)
      ..setMatrix4('VertexInfo.projection', device.projection);
  }

  void _bindJointMatrices(GraphicsDevice device) {
    final jointTransforms = device.jointsInfo.jointTransforms;
    if (jointTransforms.length > _maxJoints) {
      throw Exception(
        'At most $_maxJoints joints per surface are supported;'
        ' found ${jointTransforms.length}',
      );
    }
    for (final (index, transform) in jointTransforms.indexed) {
      vertexShader.setMatrix4('JointMatrices.joint$index', transform);
    }
  }

  void _bindMaterial(GraphicsDevice device) {
    _applyLights(device);
    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setVector3('Material.albedoColor', _albedoCache)
      ..setFloat('Material.metallic', metallic)
      ..setFloat('Material.roughness', roughness);
  }

  void _bindCamera(GraphicsDevice device) {
    final invertedView = Matrix4.inverted(device.view);
    final cameraPosition = invertedView.transform3(Vector3.zero());
    fragmentShader.setVector3('Camera.position', cameraPosition);
  }

  void _applyLights(GraphicsDevice device) {
    device.lightingInfo.apply(fragmentShader);
  }

  static const _maxJoints = 16;
}
