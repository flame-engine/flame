import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template material}
/// Base material [Resource], it holds the shader library that should be used
/// for the texture.
/// {@endtemplate}
abstract class Material extends Resource<gpu.RenderPipeline> {
  /// {@macro material}
  Material({
    required Shader vertexShader,
    required Shader fragmentShader,
  }) : _vertexShader = vertexShader,
       _fragmentShader = fragmentShader;

  @override
  gpu.RenderPipeline createResource() {
    return gpu.gpuContext.createRenderPipeline(
      _vertexShader.compile().resource,
      _fragmentShader.compile().resource,
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

  void bind(GraphicsDevice device) {}
}
