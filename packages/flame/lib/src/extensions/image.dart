import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/extensions/color.dart';
import 'package:flame/src/extensions/vector2.dart';

export 'dart:ui' show Image;

extension ImageExtension on Image {
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

  /// Returns the bounding [Rect] of the image.
  Rect getBoundingRect() => Vector2.zero() & size;

  /// Returns a [Vector2] representing the dimensions of this image.
  Vector2 get size => Vector2Extension.fromInts(width, height);

  /// Change each pixel's color to be darker and return a new [Image].
  ///
  /// The [amount] is a double value between 0 and 1.
  Future<Image> darken(double amount) async {
    assert(amount >= 0 && amount <= 1);

    final pixelData = await pixelsInUint8();
    final newPixelData = Uint8List(pixelData.length);

    for (var i = 0; i < pixelData.length; i += 4) {
      final color = Color.fromARGB(
        pixelData[i + 3],
        pixelData[i + 0],
        pixelData[i + 1],
        pixelData[i + 2],
      ).darken(amount);

      newPixelData[i] = color.red;
      newPixelData[i + 1] = color.green;
      newPixelData[i + 2] = color.blue;
      newPixelData[i + 3] = color.alpha;
    }
    return fromPixels(newPixelData, width, height);
  }

  /// Change each pixel's color to be brighter and return a new [Image].
  ///
  /// The [amount] is a double value between 0 and 1.
  Future<Image> brighten(double amount) async {
    assert(amount >= 0 && amount <= 1);

    final pixelData = await pixelsInUint8();
    final newPixelData = Uint8List(pixelData.length);

    for (var i = 0; i < pixelData.length; i += 4) {
      final color = Color.fromARGB(
        pixelData[i + 3],
        pixelData[i + 0],
        pixelData[i + 1],
        pixelData[i + 2],
      ).brighten(amount);

      newPixelData[i] = color.red;
      newPixelData[i + 1] = color.green;
      newPixelData[i + 2] = color.blue;
      newPixelData[i + 3] = color.alpha;
    }
    return fromPixels(newPixelData, width, height);
  }
}
