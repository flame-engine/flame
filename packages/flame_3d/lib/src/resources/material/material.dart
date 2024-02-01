import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/resources/resource.dart';
import 'package:flutter/foundation.dart';
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

  @mustCallSuper
  ShaderInfo getVertexInfo(Matrix4 mvp) => ShaderInfo()..addMatrix4(mvp);

  @mustCallSuper
  ShaderInfo getFragmentInfo() => ShaderInfo();
}

class ShaderInfo {
  ShaderInfo();

  final List<double> _storage = [];
  ByteBuffer get buffer => Float32List.fromList(_storage).buffer;

  void addVector2(Vector2 vector) => _storage.addAll(vector.storage);

  void addVector3(Vector3 vector) => _storage.addAll(vector.storage);

  void addVector4(Vector4 vector) => _storage.addAll(vector.storage);

  void addMatrix4(Matrix4 matrix) => _storage.addAll(matrix.storage);
}
