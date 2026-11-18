import 'dart:typed_data';
import 'dart:ui' show PixelFormat;

/// Builds the mip levels of textures on the CPU, as Flutter GPU cannot
/// generate them.
abstract final class Mipmaps() {
  /// The size of the mip [level] of a [width]x[height] texture: each level
  /// halves the previous one (rounding down), down to one pixel.
  static (int, int) levelSize(int width, int height, int level) {
    final w = width >> level;
    final h = height >> level;
    return (w < 1 ? 1 : w, h < 1 ? 1 : h);
  }

  /// The next mip level of [source], a [width]x[height] image in [format]:
  /// each of its pixels averages (a box filter over) the 2x2 pixels it
  /// covers, or fewer along an edge of a single pixel.
  ///
  /// The pixels are averaged channel by channel, which is right for
  /// premultiplied alpha, as Flutter's images use.
  static ByteData downsample(
    ByteData source,
    int width,
    int height,
    PixelFormat format,
  ) {
    final (w, h) = levelSize(width, height, 1);
    return switch (format) {
      PixelFormat.rgbaFloat32 => _downsampleFloat(source, width, height, w, h),
      _ => _downsampleBytes(source, width, height, w, h),
    };
  }

  static ByteData _downsampleBytes(
    ByteData source,
    int width,
    int height,
    int w,
    int h,
  ) {
    final src = source.buffer.asUint8List(
      source.offsetInBytes,
      source.lengthInBytes,
    );
    final dst = Uint8List(w * h * 4);
    for (var y = 0; y < h; y++) {
      final y0 = y * 2 < height ? y * 2 : height - 1;
      final y1 = y0 + 1 < height ? y0 + 1 : y0;
      for (var x = 0; x < w; x++) {
        final x0 = x * 2 < width ? x * 2 : width - 1;
        final x1 = x0 + 1 < width ? x0 + 1 : x0;
        final a = (y0 * width + x0) * 4;
        final b = (y0 * width + x1) * 4;
        final c = (y1 * width + x0) * 4;
        final d = (y1 * width + x1) * 4;
        final o = (y * w + x) * 4;
        for (var i = 0; i < 4; i++) {
          // The average, rounded to the nearest value.
          final sum = src[a + i] + src[b + i] + src[c + i] + src[d + i];
          dst[o + i] = (sum + 2) >> 2;
        }
      }
    }
    return ByteData.sublistView(dst);
  }

  static ByteData _downsampleFloat(
    ByteData source,
    int width,
    int height,
    int w,
    int h,
  ) {
    final dst = ByteData(w * h * 16);
    double at(int x, int y, int i) {
      return source.getFloat32((y * width + x) * 16 + i * 4, Endian.host);
    }

    for (var y = 0; y < h; y++) {
      final y0 = y * 2 < height ? y * 2 : height - 1;
      final y1 = y0 + 1 < height ? y0 + 1 : y0;
      for (var x = 0; x < w; x++) {
        final x0 = x * 2 < width ? x * 2 : width - 1;
        final x1 = x0 + 1 < width ? x0 + 1 : x0;
        for (var i = 0; i < 4; i++) {
          final value =
              (at(x0, y0, i) + at(x1, y0, i) + at(x0, y1, i) + at(x1, y1, i)) /
              4;
          dst.setFloat32((y * w + x) * 16 + i * 4, value, Endian.host);
        }
      }
    }
    return dst;
  }
}
