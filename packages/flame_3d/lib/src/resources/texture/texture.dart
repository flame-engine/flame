import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/gpu_context_wrapper.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template texture}
/// Base texture [Resource], represents an image/texture on the GPU.
/// {@endtemplate}
class Texture extends Resource<gpu.Texture> {
  final ByteData sourceData;
  final int width;
  final int height;
  final PixelFormat format;

  /// {@macro texture}
  Texture(
    this.sourceData, {
    required this.width,
    required this.height,
    this.format = PixelFormat.rgba8888,
  });

  @override
  gpu.Texture createResource() {
    return GpuContextWrapper(gpu.gpuContext).createTexture(
      gpu.StorageMode.hostVisible,
      width,
      height,
      format: switch (format) {
        PixelFormat.rgba8888 => gpu.PixelFormat.r8g8b8a8UNormInt,
        PixelFormat.bgra8888 => gpu.PixelFormat.b8g8r8a8UNormInt,
        PixelFormat.rgbaFloat32 => gpu.PixelFormat.r32g32b32a32Float,
      },
    )..overwrite(sourceData);
  }

  Image toImage() => resource.asImage();

  /// A transparent single pixel texture.
  static final empty = ColorTexture(const Color(0x00000000));

  /// A white single pixel texture.
  static final standard = ColorTexture(const Color(0xFFFFFFFF));
}
