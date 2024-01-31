import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/resources/resource.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

abstract class Material extends Resource<gpu.RenderPipeline> {
  Material(gpu.ShaderLibrary library)
      : super(
          gpu.gpuContext.createRenderPipeline(
            library['TextureVertex']!,
            library['TextureFragment']!,
          ),
        );

  gpu.Shader get vertexShader => resource.vertexShader;

  gpu.Shader get fragmentShader => resource.fragmentShader;

  void bind(GraphicsDevice device) {}
}
