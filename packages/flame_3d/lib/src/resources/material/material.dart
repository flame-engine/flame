import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/resources/resource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template material}
/// Base material [Resource], it holds the shader library that should be used
/// for the texture.
/// {@endtemplate}
abstract class Material extends Resource<gpu.RenderPipeline> {
  /// {@macro material}
  Material(gpu.ShaderLibrary library)
      : super(
          gpu.gpuContext.createRenderPipeline(
            library['TextureVertex']!,
            library['TextureFragment']!,
          ),
        );

  final _vertexBuffer = ShaderBuffer('VertexInfo');
  final _fragmentBuffer = ShaderBuffer('FragmentInfo');

  /// The vertex shader being used.
  gpu.Shader get vertexShader => resource.vertexShader;
  ShaderBuffer get vertexBuffer => _vertexBuffer;

  /// The fragment shader being used.
  gpu.Shader get fragmentShader => resource.fragmentShader;
  ShaderBuffer get fragmentBuffer => _fragmentBuffer;

  @mustCallSuper
  void bind(GraphicsDevice device) {
    device.bindShader(vertexShader, _vertexBuffer);
    device.bindShader(fragmentShader, fragmentBuffer);
  }
}

/// {@template shader_buffer}
/// Class that buffers all the float uniforms that have to be uploaded to a
/// shader.
/// {@endtemplate}
class ShaderBuffer {
  /// {@macro shader_buffer}
  ShaderBuffer(this.slot);

  final String slot;

  final List<double> _storage = [];
  ByteBuffer get bytes => Float32List.fromList(_storage).buffer;

  /// Add a [Vector2] to the buffer.
  void addVector2(Vector2 vector) => _storage.addAll(vector.storage);

  /// Add a [Vector3] to the buffer.
  void addVector3(Vector3 vector) => _storage.addAll(vector.storage);

  /// Add a [Vector4] to the buffer.
  void addVector4(Vector4 vector) => _storage.addAll(vector.storage);

  /// Add a [Matrix4] to the buffer.
  void addMatrix4(Matrix4 matrix) => _storage.addAll(matrix.storage);

  /// Clear the buffer.
  void clear() => _storage.clear();
}
