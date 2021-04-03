import 'dart:async';
import 'dart:convert' show base64;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui show decodeImageFromPixels;

import 'package:flutter/foundation.dart';

import '../flame.dart';

class Images {
  final String prefix;
  final Map<String, _ImageAssetLoader> _loadedFiles = {};

  Images({this.prefix = 'assets/images/'});

  void clear(String fileName) {
    _loadedFiles.remove(fileName);
  }

  void clearCache() {
    _loadedFiles.clear();
  }

  Image fromCache(String fileName) {
    final image = _loadedFiles[fileName];
    assert(
      image?.loadedImage != null,
      'Tried to access an inexistent entry on cache "$fileName", make sure to use the load method before accessing a file on the cache',
    );
    return image!.loadedImage!;
  }

  Future<List<Image>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  Future<Image> load(String fileName) async {
    if (!_loadedFiles.containsKey(fileName)) {
      _loadedFiles[fileName] = _ImageAssetLoader(_fetchToMemory(fileName));
    }
    return _loadedFiles[fileName]!.retrieve();
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

  Future<Image> fromBase64(String fileName, String base64) async {
    if (!_loadedFiles.containsKey(fileName)) {
      _loadedFiles[fileName] = _ImageAssetLoader(_fetchFromBase64(base64));
    }
    return _loadedFiles[fileName]!.retrieve();
  }

  Future<Image> _fetchFromBase64(String base64Data) async {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final bytes = base64.decode(data);
    return _loadBytes(bytes);
  }

  Future<Image> _fetchToMemory(String name) async {
    final data = await Flame.bundle.load('$prefix$name');
    final bytes = Uint8List.view(data.buffer);
    return _loadBytes(bytes);
  }

  Future<Image> _loadBytes(Uint8List bytes) {
    final completer = Completer<Image>();
    decodeImageFromList(bytes, completer.complete);
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

class _ImageAssetLoader {
  _ImageAssetLoader(this.future);

  Image? loadedImage;
  Future<Image> future;

  Future<Image> retrieve() async {
    return loadedImage ??= await future;
  }
}
