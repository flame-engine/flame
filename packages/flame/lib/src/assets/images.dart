import 'dart:async';
import 'dart:convert' show base64, json;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui show decodeImageFromPixels;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../flame.dart';

class Images {
  Images({this.prefix = 'assets/images/'})
      : assert(prefix.isEmpty || prefix.endsWith('/'));

  final String prefix;
  final Map<String, _ImageAssetLoader> _loadedFiles = {};

  /// Adds an [image] into the cache under the key [name].
  void add(String name, Image image) {
    _loadedFiles[name] = _ImageAssetLoader(Future.value(image))
      ..loadedImage = image;
  }

  /// Remove the image [name] from the cache.
  ///
  /// This calls [Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache.
  void clear(String name) {
    _loadedFiles.remove(name)?.loadedImage?.dispose();
  }

  /// Remove all cached images.
  ///
  /// This calls [Image.dispose] for all images in the cache, so make sure that
  /// you don't use any of the previously cached images once [clearCache] has
  /// been called.
  void clearCache() {
    _loadedFiles.forEach((_, imageAssetLoader) {
      imageAssetLoader.loadedImage?.dispose();
    });
    _loadedFiles.clear();
  }

  /// Gets the specified image [name] from the cache.
  Image fromCache(String name) {
    final image = _loadedFiles[name];
    assert(
      image?.loadedImage != null,
      'Tried to access a nonexistent entry on cache "$name", make sure to '
      'use the load method before accessing a file on the cache',
    );
    return image!.loadedImage!;
  }

  /// Loads the specified image with [fileName] into the cache.
  Future<Image> load(String fileName) async {
    if (!_loadedFiles.containsKey(fileName)) {
      _loadedFiles[fileName] = _ImageAssetLoader(_fetchToMemory(fileName));
    }
    return _loadedFiles[fileName]!.retrieve();
  }

  /// Load all images with the specified [fileNames] into the cache.
  Future<List<Image>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  /// Loads all images from the specified (or default) [prefix] into the cache.
  Future<List<Image>> loadAllImages() async {
    return loadAllFromPattern(
      RegExp(
        r'\.(png|jpg|jpeg|svg|gif|webp|bmp|wbmp)$',
        caseSensitive: false,
      ),
    );
  }

  /// Loads all images in the [prefix]ed path that are matching the specified
  /// pattern.
  Future<List<Image>> loadAllFromPattern(Pattern pattern) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final imagePaths = manifestMap.keys.where((path) {
      return path.startsWith(prefix) && path.toLowerCase().contains(pattern);
    }).map((path) => path.replaceFirst(prefix, ''));
    return loadAll(imagePaths.toList());
  }

  /// Convert an array of pixel values into an [Image] object.
  ///
  /// The [pixels] parameter is the pixel data in the encoding described by
  /// [PixelFormat.rgba8888], the encoding can't be changed to allow for web
  /// support.
  ///
  /// If you want the image to be decoded as it would be on the web you can set
  /// [runAsWeb] to `true`. Keep in mind that it is slightly slower than the
  /// native [ui.decodeImageFromPixels]. By default it is set to [kIsWeb].
  @Deprecated(
    'Use Image.fromPixels() instead. This function will be removed in 1.1.0',
  )
  Future<Image> decodeImageFromPixels(
    Uint8List pixels,
    int width,
    int height, {
    bool runAsWeb = false,
  }) {
    final completer = Completer<Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      PixelFormat.rgba8888,
      completer.complete,
    );
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
}

class _ImageAssetLoader {
  _ImageAssetLoader(this.future);

  Image? loadedImage;
  Future<Image> future;

  Future<Image> retrieve() async {
    return loadedImage ??= await future;
  }
}
