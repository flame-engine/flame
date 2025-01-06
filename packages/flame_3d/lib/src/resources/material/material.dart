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
  })  : _vertexShader = vertexShader,
        _fragmentShader = fragmentShader,
        super(
          gpu.gpuContext.createRenderPipeline(
            vertexShader.compile().resource,
            fragmentShader.compile().resource,
          ),
        );

  @override
  gpu.RenderPipeline get resource {
    var resource = super.resource;
    if (_recreateResource) {
      resource = super.resource = gpu.gpuContext.createRenderPipeline(
        _vertexShader.compile().resource,
        _fragmentShader.compile().resource,
      );
      _recreateResource = false;
    }
    return resource;
  }

  bool _recreateResource = false;

  Shader get vertexShader => _vertexShader;
  Shader _vertexShader;
  set vertexShader(Shader shader) {
    _vertexShader = shader;
    _recreateResource = true;
  }

  Shader get fragmentShader => _fragmentShader;
  Shader _fragmentShader;
  set fragmentShader(Shader shader) {
    _fragmentShader = shader;
    _recreateResource = true;
  }

  void bind(GraphicsDevice device) {}
}
