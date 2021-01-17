import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui show decodeImageFromPixels;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'extensions/vector2.dart';

/// Some utilities that did not fit anywhere else.
///
/// To use this class, access it via [Flame.util].
class Util {
  /// Sets the app to be fullscreen (no buttons bar os notifications on top).
  ///
  /// Most games should probably be this way.
  Future<void> fullScreen() {
    if (kIsWeb) {
      return Future.value();
    }
    return SystemChrome.setEnabledSystemUIOverlays([]);
  }

  /// Sets the preferred orientation (landscape or portrait) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientation(DeviceOrientation orientation) {
    if (kIsWeb) {
      return Future.value();
    }
    return SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[orientation],
    );
  }

  /// Sets the preferred orientations (landscape left, right, portrait up, or down) for the app.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible) depending on the physical orientation of the device.
  Future<void> setOrientations(List<DeviceOrientation> orientations) {
    if (kIsWeb) {
      return Future.value();
    }
    return SystemChrome.setPreferredOrientations(orientations);
  }

  /// Sets the preferred orientation of the app to landscape only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscape() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.landscapeLeft` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscapeLeftOnly() {
    return setOrientation(DeviceOrientation.landscapeLeft);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.landscapeRight` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setLandscapeRightOnly() {
    return setOrientation(DeviceOrientation.landscapeRight);
  }

  /// Sets the preferred orientation of the app to portrait only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortrait() {
    return setOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.portraitUp` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortraitUpOnly() {
    return setOrientation(DeviceOrientation.portraitUp);
  }

  /// Sets the preferred orientation of the app to `DeviceOrientation.portraitDown` only.
  ///
  /// When it opens, it will automatically change orientation to the preferred one (if possible).
  Future<void> setPortraitDownOnly() {
    return setOrientation(DeviceOrientation.portraitDown);
  }

  /// Utility method to render stuff on a specific place.
  ///
  /// Some render methods don't allow to pass a offset.
  /// This method translate the canvas before rendering your fn.
  /// The changes are reset after the fn is run.
  void renderAt(Canvas c, Vector2 p, void Function(Canvas) fn) {
    c.save();
    c.translate(p.x, p.y);
    fn(c);
    c.restore();
  }

  /// Utility method to render stuff rotated at specific angle.
  ///
  /// It rotates the canvas around the center of rotation.
  /// The changes are reset after the fn is run.
  void renderRotated(
    Canvas c,
    double angle,
    Vector2 rotationCenter,
    void Function(Canvas) fn,
  ) {
    c.save();
    c.translate(-rotationCenter.x, -rotationCenter.y);
    c.rotate(angle);
    c.translate(rotationCenter.x, rotationCenter.y);
    fn(c);
    c.restore();
  }

  /// Convert an array of pixel values into an [Image] object.
  ///
  /// The [pixels] parameter is the pixel data in the encoding described by
  /// [PixelFormat.rgba8888], the encoding can't be changed to allow for web support.
  ///
  /// If you want the image to be decoded as it would be on the web you can set
  /// [runAsWeb] to `true`. Keep in mind that it is slightly slower than the native
  /// [ui.decodeImageFromPixels]. By default it is set to [kIsWeb].
  Future<Image> decodeImageFromPixels(
    Uint8List pixels,
    int width,
    int height, {
    bool runAsWeb = kIsWeb,
  }) {
    final completer = Completer<Image>();
    if (runAsWeb) {
      completer.complete(_createBmp(pixels, width, height));
    } else {
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        PixelFormat.rgba8888,
        completer.complete,
      );
    }

    return completer.future;
  }

  Future<Image> _createBmp(Uint8List pixels, int width, int height) async {
    final size = (width * height * 4) + 122;
    final bmp = Uint8List(size);
    bmp.buffer.asByteData()
      ..setUint8(0x0, 0x42)
      ..setUint8(0x1, 0x4d)
      ..setInt32(0x2, size, Endian.little)
      ..setInt32(0xa, 122, Endian.little)
      ..setUint32(0xe, 108, Endian.little)
      ..setUint32(0x12, width, Endian.little)
      ..setUint32(0x16, -height, Endian.little)
      ..setUint16(0x1a, 1, Endian.little)
      ..setUint32(0x1c, 32, Endian.little)
      ..setUint32(0x1e, 3, Endian.little)
      ..setUint32(0x22, width * height * 4, Endian.little)
      ..setUint32(0x36, 0x000000ff, Endian.little)
      ..setUint32(0x3a, 0x0000ff00, Endian.little)
      ..setUint32(0x3e, 0x00ff0000, Endian.little)
      ..setUint32(0x42, 0xff000000, Endian.little);

    bmp.setRange(122, size, pixels);

    final codec = await instantiateImageCodec(bmp);
    final frame = await codec.getNextFrame();

    return frame.image;
  }
}
