import 'dart:async';
import 'dart:convert' show base64, json;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui show decodeImageFromPixels;

import 'package:flame/src/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Images {
  Images({String prefix = 'assets/images/'}) {
    this.prefix = prefix;
  }

  final Map<String, _ImageAsset> _assets = {};

  /// Path prefix to the project's directory with images.
  ///
  /// This path is relative to the project's root, and the default prefix is
  /// "assets/images/". If necessary, you may change this prefix at any time.
  /// A prefix must be a valid directory name and end with "/" (empty prefix is
  /// also allowed).
  ///
  /// The prefix is **not** part of the keys of the images stored in this cache.
  /// For example, if you load image `player.png`, then it will be searched at
  /// location `prefix + "player.png"` but stored in the cache under the key
  /// `"player.png"`.
  String get prefix => _prefix;
  late String _prefix;
  set prefix(String value) {
    assert(
      value.isEmpty || value.endsWith('/'),
      'Prefix must be empty or end with a "/"',
    );
    _prefix = value;
  }

  /// Adds the [image] into the cache under the key [name].
  ///
  /// The cache will assume the ownership of the [image], and will properly
  /// dispose of it at the end.
  void add(String name, Image image) {
    _assets[name]?.dispose();
    _assets[name] = _ImageAsset.fromImage(image);
  }

  /// Removes the image [name] from the cache.
  ///
  /// No error is raised if the image [name] is not present in the cache.
  ///
  /// This calls [Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache.
  void clear(String name) {
    final removedAsset = _assets.remove(name);
    removedAsset?.dispose();
  }

  /// Removes all cached images.
  ///
  /// This calls [Image.dispose] for all images in the cache, so make sure that
  /// you don't use any of the previously cached images once [clearCache] has
  /// been called.
  void clearCache() {
    _assets.forEach((_, asset) => asset.dispose());
    _assets.clear();
  }

  /// Returns the image [name] from the cache.
  ///
  /// The image returned can be used as long as it remains in the cache, but
  /// doesn't need to be explicitly disposed.
  ///
  /// If you want to retain the image even after you remove it from the cache,
  /// then you can call `Image.clone()` on it.
  Image fromCache(String name) {
    final asset = _assets[name];
    assert(
      asset != null,
      'Tried to access an image "$name" that does not exist in the cache. Make '
      'sure to load() an image before accessing it',
    );
    assert(
      asset!.image != null,
      'Tried to access an image "$name" before it was loaded. Make sure to '
      'await the future from load() before using this method',
    );
    return asset!.image!;
  }

  /// Loads the specified image with [fileName] into the cache.
  /// By default the key in the cache is the [fileName], if another key is
  /// desired, specify the optional [key] argument.
  Future<Image> load(String fileName, {String? key}) {
    return (_assets[key ?? fileName] ??=
            _ImageAsset.future(_fetchToMemory(fileName)))
        .retrieveAsync();
  }

  /// Loads all images with the specified [fileNames] into the cache.
  Future<List<Image>> loadAll(List<String> fileNames) {
    return Future.wait(fileNames.map(load));
  }

  /// Loads all images from the specified (or default) [prefix] into the cache.
  Future<List<Image>> loadAllImages() {
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
      return path.startsWith(_prefix) && path.toLowerCase().contains(pattern);
    }).map((path) => path.replaceFirst(_prefix, ''));
    return loadAll(imagePaths.toList());
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(String key) => _assets.containsKey(key);

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  /// Converts an array of pixel values into an [Image] object.
  ///
  /// The [pixels] parameter is the pixel data in the encoding described by
  /// [PixelFormat.rgba8888], the encoding can't be changed to allow for web
  /// support.
  ///
  /// If you want the image to be decoded as it would be on the web you can set
  /// [runAsWeb] to `true`. Keep in mind that it is slightly slower than the
  /// native [ui.decodeImageFromPixels]. By default it is set to [kIsWeb].
  @Deprecated(
    'Use Image.fromPixels() instead. This method will be removed in v1.2.0',
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

  Future<Image> fromBase64(String key, String base64) {
    return (_assets[key] ??= _ImageAsset.future(_fetchFromBase64(base64)))
        .retrieveAsync();
  }

  Future<Image> _fetchFromBase64(String base64Data) {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final bytes = base64.decode(data);
    return _loadBytes(bytes);
  }

  Future<Image> _fetchToMemory(String name) async {
    final data = await Flame.bundle.load('$_prefix$name');
    final bytes = Uint8List.view(data.buffer);
    return _loadBytes(bytes);
  }

  Future<Image> _loadBytes(Uint8List bytes) {
    final completer = Completer<Image>();
    decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }
}

/// Individual entry in the [Images] cache.
///
/// This class owns the [Image] object, which can be disposed of using the
/// [dispose] method.
class _ImageAsset {
  _ImageAsset.future(Future<Image> future) : _future = future {
    _future!.then((image) {
      _image = image;
      _future = null;
    });
  }

  _ImageAsset.fromImage(Image image) : _image = image;

  Image? get image => _image;
  Image? _image;

  Future<Image>? _future;

  Future<Image> retrieveAsync() => _future ?? Future.value(_image);

  /// Properly dispose of an image asset.
  void dispose() {
    if (_image != null) {
      _image!.dispose();
      _image = null;
    }
    if (_future != null) {
      _future!.then((image) => image.dispose());
      _future = null;
    }
  }
}
