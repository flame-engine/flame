import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

/// {@template texture}
/// Base texture [Resource], represents an image/texture on the GPU.
/// {@endtemplate}
class Texture extends Resource<gpu.Texture> {
  /// {@macro texture}
  Texture(
    ByteData sourceData, {
    required int width,
    required int height,
    PixelFormat format = PixelFormat.rgba8888,
  }) : super(
          gpu.gpuContext.createTexture(
            gpu.StorageMode.hostVisible,
            width,
            height,
            format: switch (format) {
              PixelFormat.rgba8888 => gpu.PixelFormat.r8g8b8a8UNormInt,
              PixelFormat.bgra8888 => gpu.PixelFormat.b8g8r8a8UNormInt,
              PixelFormat.rgbaFloat32 => gpu.PixelFormat.r32g32b32a32Float,
            },
          )!
            ..overwrite(sourceData),
        );

  int get width => resource.width;

  int get height => resource.height;

  Image toImage() => resource.asImage();

  /// A transparent single pixel texture.
  static final empty = ColorTexture(const Color(0x00000000));

  /// A white single pixel texture.
  static final standard = ColorTexture(const Color(0xFFFFFFFF));
}
