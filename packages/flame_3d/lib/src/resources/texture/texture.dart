import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class Texture extends Resource<gpu.Texture> {
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

  static final empty = ColorTexture(const Color(0x00000000));

  static final standard = ColorTexture(const Color(0xFFFFFFFF));
}
