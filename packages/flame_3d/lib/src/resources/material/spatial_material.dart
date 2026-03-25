import 'dart:ui' hide FragmentShader;

import 'package:flame_3d/game.dart';
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
         vertexShader: VertexShader.fromAsset(
           'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: ['VertexInfo', 'JointMatrices'],
         ),
         fragmentShader: FragmentShader.fromAsset(
           'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
           slots: [
             'albedoTexture',
             'Material',
             'AmbientLight',
             'Lights',
             'Camera',
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
      vertexShader.setMatrix4('JointMatrices.joints[$index]', transform);
    }
  }

  void _bindMaterial(GraphicsDevice device) {
    _applyLights(device);
    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setColor('Material.albedoColor', albedoColor)
      ..setFloat('Material.metallic', metallic)
      ..setFloat('Material.roughness', roughness);
  }

  void _bindCamera(GraphicsDevice device) {
    final invertedView = Matrix4.inverted(device.view);
    final cameraPosition = invertedView.transform3(Vector3.zero());
    fragmentShader.setVector3('Camera.position', cameraPosition);
  }

  void _applyLights(GraphicsDevice device) {
    final lights = device.lights;

    // Apply ambient light (at most one, fallback to default).
    final ambient =
        lights.map((e) => e.source).whereType<AmbientLight>().firstOrNull ??
        AmbientLight();
    fragmentShader
      ..setColor('AmbientLight.color', ambient.color)
      ..setFloat('AmbientLight.intensity', ambient.intensity);

    // Apply point lights.
    final points = lights.where((e) => e.source is PointLight);

    // NOTE: using floats because Android GLES does not support integer uniforms
    // Refer to https://github.com/flutter/engine/pull/55329
    fragmentShader.setFloat('Lights.numLights', points.length.toDouble());

    for (final (index, light) in points.indexed) {
      fragmentShader
        ..setVector3('Lights.positions[$index]', light.position)
        ..setColor('Lights.colors[$index]', light.source.color)
        ..setFloat('Lights.intensities[$index]', light.source.intensity);
    }
  }

  static const _maxJoints = 16;
}
