import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/resources/texture/mipmaps.dart';

/// {@template texture}
/// Base texture [Resource], represents an image/texture on the GPU.
///
/// The texture is uploaded from [sourceData] (tightly packed rows of [width]
/// pixels in [format]) the first time it is used, or wraps a [gpuTexture]
/// that is already on the GPU.
///
/// It is sampled as its [sampler] says, which may be changed at any time.
/// With [mipmaps], the mip levels are built on the CPU (by averaging 2x2
/// pixels per level) and uploaded with it, so that the texture does not
/// shimmer when drawn small; use a [sampler] whose `minFilter` and `mipFilter`
/// are linear to blend them. Mipmaps are skipped for wrapped textures and on
/// devices that cannot sample mip levels uploaded by hand.
/// {@endtemplate}
class Texture(
  /// The pixels to upload, or `null` when the texture wraps a [gpuTexture].
  final ByteData? sourceData, {
  required final int width,
  required final int height,
  final PixelFormat format = PixelFormat.rgba8888,

  /// How the texture is sampled.
  var TextureSampler sampler = TextureSampler.nearest,

  /// Whether to build and upload mip levels.
  final bool mipmaps = false,

  /// A texture already on the GPU, used instead of uploading [sourceData].
  final GpuTexture? gpuTexture,
}) extends Resource<GpuTexture> {
  /// {@macro texture}
  this
    : assert(
        sourceData != null || gpuTexture != null,
        'A texture needs source data or a GPU texture',
      );

  @override
  GpuTexture createResource() {
    final wrapped = gpuTexture;
    if (wrapped != null) {
      return wrapped;
    }
    final data = sourceData!;
    final backend = GpuBackend.instance;
    final levels = mipmaps ? backend.maxMipLevelCount(width, height) : 1;
    final texture = backend.createTexture(
      storageMode: GpuStorageMode.hostVisible,
      width: width,
      height: height,
      format: switch (format) {
        PixelFormat.rgba8888 => GpuPixelFormat.rgba8888,
        PixelFormat.bgra8888 => GpuPixelFormat.bgra8888,
        PixelFormat.rgbaFloat32 => GpuPixelFormat.rgbaFloat32,
        _ => throw UnsupportedError('Unsupported pixel format: $format'),
      },
      mipLevelCount: levels,
    )..write(data);
    var level = data;
    for (var i = 1; i < levels; i++) {
      final (w, h) = Mipmaps.levelSize(width, height, i - 1);
      level = Mipmaps.downsample(level, w, h, format);
      texture.write(level, mipLevel: i);
    }
    return texture;
  }

  /// The number of mip levels of the texture on the GPU, `1` without
  /// mipmaps.
  int get mipLevelCount => resource.mipLevelCount;

  Image toImage() => resource.asImage();

  /// A transparent single pixel texture.
  static final empty = ColorTexture(const Color(0x00000000));

  /// A white single pixel texture.
  static final standard = ColorTexture(const Color(0xFFFFFFFF));
}
