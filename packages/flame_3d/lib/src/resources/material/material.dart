import 'package:flame_3d/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

abstract class Material {
  Material(gpu.ShaderLibrary library)
      : _pipeline = gpu.gpuContext.createRenderPipeline(
          library['TextureVertex']!,
          library['TextureFragment']!,
        );

  final gpu.RenderPipeline _pipeline;

  gpu.Shader get vertexShader => _pipeline.vertexShader;

  gpu.Shader get fragmentShader => _pipeline.fragmentShader;

  @mustCallSuper
  void bind(gpu.RenderPass pass, gpu.HostBuffer buffer, Matrix4 mvp) {
    pass
      ..bindPipeline(_pipeline)
      ..bindUniform(
        vertexShader.getUniformSlot('mvp')!,
        buffer.emplace(mvp.storage.buffer.asByteData()),
      );
  }
}
