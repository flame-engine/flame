import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template standard_material}
/// The standard material, it applies the [albedoColor] to the [albedoTexture].
/// {@endtemplate}
class StandardMaterial extends Material {
  /// {@macro standard_material}
  StandardMaterial({
    Texture? albedoTexture,
    Color? albedoColor,
  })  : albedoTexture = albedoTexture ?? Texture.standard,
        _albedoColorCache = Vector4.zero(),
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
              // UniformSlot.struct('FragmentInfo', [
              //   'albedoColor',
              // ]),
              UniformSlot.value('Material', {
                'albedoColor',
                'ambient', // vec3
                'diffuse', // vec3
                'specular', // vec3
                'roughness', // float
              }),
              UniformSlot.value('Light', {
                'position', // vec3
                'ambient', // vec3
                'diffuse', // vec3
                'specular', // vec3
              }),
              UniformSlot.value('Camera', {
                'position', // vec3
              }),
            ],
          ),
        ) {
    this.albedoColor = albedoColor ?? const Color(0xFFFFFFFF);
  }

  final Vector3 ambient = Vector3.all(0);

  final Vector3 diffuse = Vector3.all(1.0);

  final Vector3 specular = Vector3.all(1.0);

  double roughness = 0.2;

  Texture albedoTexture;

  Color get albedoColor => _albedoColor;
  set albedoColor(Color color) {
    _albedoColor = color;
    _albedoColorCache.setValues(
      color.red / 255,
      color.green / 255,
      color.blue / 255,
      color.alpha / 255,
    );
  }

  late Color _albedoColor;
  final Vector4 _albedoColorCache;

  @override
  void bind(GraphicsDevice device) {
    vertexShader
      ..setMatrix4('VertexInfo.model', device.model)
      ..setMatrix4('VertexInfo.view', device.view)
      ..setMatrix4('VertexInfo.projection', device.projection);

    final invertedView = Matrix4.inverted(device.view);

    final lightColor = Vector3.all(1);
    final diffuseColor = lightColor; // * 0.5;
    final ambientColor = diffuseColor; // * 0.2;

    fragmentShader
      ..setTexture('albedoTexture', albedoTexture)
      ..setVector4('Material.albedoColor', _albedoColorCache)
      // ..setVector4('FragmentInfo.albedoColor', _albedoColorCache)
      // Material
      ..setVector3('Material.ambient', ambient)
      ..setVector3('Material.diffuse', diffuse)
      ..setVector3('Material.specular', specular)
      ..setFloat('Material.roughness', roughness)
      // Light
      ..setVector3('Light.position', Vector3(10, 10, 0))
      ..setVector3('Light.ambient', ambientColor)
      ..setVector3('Light.diffuse', diffuseColor)
      ..setVector3('Light.specular', Vector3.all(1.0))
      // Camera
      ..setVector3('Camera.position', invertedView.transform3(Vector3.zero()));
  }

  static final _library = gpu.ShaderLibrary.fromAsset(
    'packages/flame_3d/assets/shaders/standard_material.shaderbundle',
  )!;
}
