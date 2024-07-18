import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class SpatialMaterial extends Material {
  SpatialMaterial({
    Texture? albedoTexture,
    Color albedoColor = const Color(0xFFFFFFFF),
    this.metallic = 0,
    this.metallicSpecular = 0.5,
    this.roughness = 1.0,
  })  : albedoTexture = albedoTexture ?? Texture.standard,
        super(
          vertexShader: Shader(
            _library['TextureVertex']!,
            slots: [
              UniformSlot.value('VertexInfo', {'model', 'view', 'projection'}),
            ],
          ),
          fragmentShader: Shader(
            _library['TextureFragment']!,
            slots: [
              UniformSlot.sampler('albedoTexture'),
              UniformSlot.value('Material', {
                'albedoColor',
                'metallic',
                'metallicSpecular',
                'roughness',
              }),
              Light.shaderSlot,
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

  double metallicSpecular;

  double roughness;

  @override
  void bind(GraphicsDevice device) {
    _bindVertexInfo(device);
    _bindMaterial(device);
    _bindCamera(device);
  }

  void _bindVertexInfo(GraphicsDevice device) {
    vertexShader
      ..setMatrix4('VertexInfo.model', device.model)
      ..setMatrix4('VertexInfo.view', device.view)
      ..setMatrix4('VertexInfo.projection', device.projection);
  }

  void _bindMaterial(GraphicsDevice device) {
    _applyLights(device);
    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setVector3('Material.albedoColor', _albedoCache)
      ..setFloat('Material.metallic', metallic)
      ..setFloat('Material.metallicSpecular', metallicSpecular)
      ..setFloat('Material.roughness', roughness);
  }

  void _bindCamera(GraphicsDevice device) {
    final invertedView = Matrix4.inverted(device.view);
    final cameraPosition = invertedView.transform3(Vector3.zero());
    fragmentShader.setVector3('Camera.position', cameraPosition);
  }

  void _applyLights(GraphicsDevice device) {
    final light = device.lights.firstOrNull;
    if (light == null) {
      return;
    }
    light.apply(fragmentShader);
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/spatial_material.shaderbundle',
  )!;
}
