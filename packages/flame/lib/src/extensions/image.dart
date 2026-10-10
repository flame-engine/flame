import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/src/geometry/alpha_contours.dart';

export 'dart:ui' show Image;

extension ImageExtension on Image {
  static final Paint _whitePaint = BasicPalette.white.paint();

  /// Converts a raw list of pixel values into an [Image] object.
  ///
  /// The pixels must be in the RGBA format, i.e. first 4 bytes encode the red,
  /// green, blue, and alpha components of the first pixel, next 4 bytes encode
  /// the next pixel, and so on. The pixels are in the row-major order, meaning
  /// that first [width] pixels encode the first row of the image, next [width]
  /// pixels the second row, and so on.
  static Future<Image> fromPixels(Uint8List pixels, int width, int height) {
    assert(pixels.length == width * height * 4);
    final completer = Completer<Image>();
    decodeImageFromPixels(
      pixels,
      width,
      height,
      PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  /// Helper method to retrieve the pixel data of the image as a [Uint8List].
  ///
  /// Pixel order used the [ImageByteFormat.rawRgba] meaning it is: R G B A.
  Future<Uint8List> pixelsInUint8() async {
    return (await toByteData())!.buffer.asUint8List();
  }

  Future<Image> transformPixels(
    Color Function(Color) transform, {
    bool reversePremultipliedAlpha = true,
  }) async {
    final pixelData = await pixelsInUint8();
    final newPixelData = Uint8List(pixelData.length);

    for (var i = 0; i < pixelData.length; i += 4) {
      final r = pixelData[i + 0] / 255;
      final g = pixelData[i + 1] / 255;
      final b = pixelData[i + 2] / 255;
      final a = pixelData[i + 3] / 255;

      final d = a == 0 || !reversePremultipliedAlpha ? 1 : a;

      // Reverse the pre-multiplied alpha.
      final color = Color.from(
        alpha: a,
        red: r / d,
        green: g / d,
        blue: b / d,
      );

      final newColor = a == 0 ? color : transform(color);

      final newR = newColor.r;
      final newG = newColor.g;
      final newB = newColor.b;

      // Pre-multiply the alpha back into the new color.
      newPixelData[i + 0] = (newR * d * 255).round();
      newPixelData[i + 1] = (newG * d * 255).round();
      newPixelData[i + 2] = (newB * d * 255).round();
      newPixelData[i + 3] = pixelData[i + 3];
    }

    return await fromPixels(newPixelData, width, height);
  }

  /// Returns the outlines of the parts of this image that are not transparent,
  /// as the closed contours of a [Path].
  ///
  /// Only the pixels in the [region] are considered, the whole image by
  /// default, and the contours are relative to its top left corner. They are
  /// scaled from the size of the [region] to the given [size], when there is
  /// one. The [region] has to be within the image, and its sides are rounded
  /// to whole pixels.
  ///
  /// A pixel is part of the outlined area when its alpha is at least the
  /// [alphaThreshold], which is between zero, excluded, and one. The outlines
  /// pass between the pixels, at the point where the alpha would reach the
  /// [alphaThreshold] if it changed linearly between their centers, so that the
  /// anti-aliased edges of the image are followed more closely than a pixel,
  /// and they stay within the [region]. Only the outer outlines are kept, not
  /// the ones of the holes in the areas, and the separate areas give separate
  /// contours.
  ///
  /// The contours are meant to make hitboxes that follow the outline of the
  /// image, like a `PathHitbox`, or a `PolygonHitbox` from one of them, which
  /// simplify them according to their sampling.
  ///
  /// Keep in mind that this reads back the pixels of the whole image, even
  /// when the [region] is only a part of it, so it is an expensive operation
  /// that should be done when loading, not in the game loop. To trace several
  /// regions of the same image, like the sprites of a sprite sheet, read the
  /// pixels once with [pixelsInUint8] and pass them to [contourFromPixels] for
  /// each region.
  Future<Path> contour({
    Rect? region,
    Vector2? size,
    double alphaThreshold = 0.5,
  }) async {
    return contourFromPixels(
      await pixelsInUint8(),
      width,
      height,
      region: region,
      size: size,
      alphaThreshold: alphaThreshold,
    );
  }

  /// Returns the outlines of the parts of a raw list of [pixels] that are not
  /// transparent, as the closed contours of a [Path].
  ///
  /// The [pixels] are in the RGBA format, as in [fromPixels]. See [contour]
  /// for the [region], [size] and [alphaThreshold] parameters.
  static Path contourFromPixels(
    Uint8List pixels,
    int width,
    int height, {
    Rect? region,
    Vector2? size,
    double alphaThreshold = 0.5,
  }) {
    assert(pixels.length == width * height * 4);
    assert(
      alphaThreshold > 0 && alphaThreshold <= 1,
      'The alpha threshold has to be in (0, 1]: $alphaThreshold',
    );
    final left = region?.left.round() ?? 0;
    final top = region?.top.round() ?? 0;
    final right = region?.right.round() ?? width;
    final bottom = region?.bottom.round() ?? height;
    // A region that is clamped to the image would move and stretch the
    // contours, relative to the region that was asked for.
    assert(
      left >= 0 && top >= 0 && right <= width && bottom <= height,
      'The region $region is not within the image of $width x $height',
    );
    assert(right >= left && bottom >= top, 'The region $region is inverted');
    final columns = right - left;
    final rows = bottom - top;
    return traceAlphaContours(
      pixels,
      width: width,
      left: left,
      top: top,
      columns: columns,
      rows: rows,
      threshold: alphaThreshold,
      scaleX: size == null || columns == 0 ? 1 : size.x / columns,
      scaleY: size == null || rows == 0 ? 1 : size.y / rows,
    );
  }

  /// Returns the bounding [Rect] of the image.
  Rect getBoundingRect() => Vector2.zero() & size;

  /// Returns a [Vector2] representing the dimensions of this image.
  Vector2 get size => Vector2Extension.fromInts(width, height);

  /// Change each pixel's color to be darker and return a new [Image].
  ///
  /// The [amount] is a double value between 0 and 1.
  Future<Image> darken(
    double amount, {
    bool reversePremultipliedAlpha = true,
  }) async {
    assert(amount >= 0 && amount <= 1);

    return await transformPixels(
      (color) => color.darken(amount),
      reversePremultipliedAlpha: reversePremultipliedAlpha,
    );
  }

  /// Change each pixel's color to be brighter and return a new [Image].
  ///
  /// The [amount] is a double value between 0 and 1.
  Future<Image> brighten(
    double amount, {
    bool reversePremultipliedAlpha = false,
  }) async {
    assert(amount >= 0 && amount <= 1);

    return await transformPixels(
      (color) => color.brighten(amount),
      reversePremultipliedAlpha: reversePremultipliedAlpha,
    );
  }

  /// Resizes this image to the given [newSize].
  ///
  /// Keep in mind that is considered an expensive operation and should be
  /// avoided in the game loop methods. Prefer using it
  /// in the loading phase of the game or components.
  Future<Image> resize(Vector2 newSize) async {
    final recorder = PictureRecorder();
    Canvas(recorder).drawImageRect(
      this,
      getBoundingRect(),
      newSize.toRect(),
      _whitePaint,
    );
    final picture = recorder.endRecording();
    final resizedImage = await picture.toImageSafe(
      newSize.x.toInt(),
      newSize.y.toInt(),
    );
    return resizedImage;
  }
}
