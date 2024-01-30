import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/resources.dart';
import 'package:flutter/widgets.dart' show mustCallSuper;
import 'package:flutter_gpu/gpu.dart' as gpu;

class Texture {
  Texture(
    ByteData source, {
    required int width,
    required int height,
    PixelFormat format = PixelFormat.rgba8888,
  }) : _texture = gpu.gpuContext.createTexture(
          gpu.StorageMode.hostVisible,
          width,
          height,
          format: switch (format) {
            PixelFormat.rgba8888 => gpu.PixelFormat.r8g8b8a8UNormInt,
            PixelFormat.bgra8888 => gpu.PixelFormat.b8g8r8a8UNormInt,
            PixelFormat.rgbaFloat32 => gpu.PixelFormat.r32g32b32a32Float,
          },
        )!
          ..overwrite(source);

  final gpu.Texture _texture;

  int get width => _texture.width;

  int get height => _texture.height;

  @mustCallSuper
  void bind(gpu.UniformSlot slot, gpu.RenderPass pass) {
    pass.bindTexture(slot, _texture);
  }

  Image toImage() => _texture.asImage();

  static final empty = ColorTexture(const Color(0x00000000));
}
