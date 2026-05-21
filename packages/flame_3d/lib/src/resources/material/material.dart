import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template material}
/// Base material [Resource], it holds the shader library that should be used
/// for the material.
/// {@endtemplate}
abstract class Material extends Resource<GpuPipeline> {
  /// {@macro material}
  Material({
    required Shader vertexShader,
    required Shader fragmentShader,
  }) : _vertexShader = vertexShader,
       _fragmentShader = fragmentShader;

  static Material defaultMaterial = SpatialMaterial()
    ..albedoColor = const Color(0xFFFF00FF);

  @override
  GpuPipeline createResource() {
    return GpuBackend.instance.createPipeline(
      vertexShader: _vertexShader.resource,
      fragmentShader: _fragmentShader.resource,
    );
  }

  Shader get vertexShader => _vertexShader;
  Shader _vertexShader;
  set vertexShader(Shader shader) {
    _vertexShader = shader;
    recreateResource = true;
  }

  Shader get fragmentShader => _fragmentShader;
  Shader _fragmentShader;
  set fragmentShader(Shader shader) {
    _fragmentShader = shader;
    recreateResource = true;
  }

  /// Face culling mode for this material. Defaults to [CullMode.none].
  CullMode cullMode = CullMode.none;

  void apply(RenderContext context) {}
}
