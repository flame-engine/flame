import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template texture}
/// Base texture [Resource], represents an image/texture on the GPU.
/// {@endtemplate}
class Texture extends Resource<GpuTexture> {
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
  GpuTexture createResource() {
    return GpuBackend.instance.createTexture(
      storageMode: GpuStorageMode.hostVisible,
      width: width,
      height: height,
      format: switch (format) {
        PixelFormat.rgba8888 => GpuPixelFormat.rgba8888,
        PixelFormat.bgra8888 => GpuPixelFormat.bgra8888,
        PixelFormat.rgbaFloat32 => GpuPixelFormat.rgbaFloat32,
        _ => throw UnsupportedError('Unsupported pixel format: $format'),
      },
    )..write(sourceData);
  }

  Image toImage() => resource.asImage();

  /// A transparent single pixel texture.
  static final empty = ColorTexture(const Color(0x00000000));

  /// A white single pixel texture.
  static final standard = ColorTexture(const Color(0xFFFFFFFF));
}
