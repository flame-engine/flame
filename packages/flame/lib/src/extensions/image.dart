import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';

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
      final a = pixelData[i + 3] / 255;

      if (a == 0) {
        newPixelData[i + 0] = pixelData[i + 0];
        newPixelData[i + 1] = pixelData[i + 1];
        newPixelData[i + 2] = pixelData[i + 2];
        newPixelData[i + 3] = pixelData[i + 3];
        continue;
      }

      // Reverse the pre-multiplied alpha.
      final color = Color.from(
        alpha: a,
        red: (pixelData[i + 0] / 255) / a,
        green: (pixelData[i + 1] / 255) / a,
        blue: (pixelData[i + 2] / 255) / a,
      );

      final newColor = transform(color);
      final r = newColor.r;
      final g = newColor.g;
      final b = newColor.b;

      // Pre-multiply the alpha back into the new color.
      newPixelData[i + 0] = (r * a * 255).round();
      newPixelData[i + 1] = (g * a * 255).round();
      newPixelData[i + 2] = (b * a * 255).round();
      newPixelData[i + 3] = pixelData[i + 3];
    }

    return fromPixels(newPixelData, width, height);
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

    return transformPixels(
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

    return transformPixels(
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
