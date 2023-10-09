import 'dart:async';
import 'dart:convert' show base64, json;
import 'dart:ui';

import 'package:flame/src/flame.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class Images {
  Images({
    String prefix = 'assets/images/',
    AssetBundle? bundle,
  }) {
    this.prefix = prefix;
    this.bundle = bundle ?? Flame.bundle;
  }

  final Map<String, _ImageAsset> _assets = {};

  /// The [AssetBundle] from which images are loaded.
  /// defaults to [Flame.bundle].
  late AssetBundle bundle;

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

  /// If the image with [name] exists in the cache that is returned, otherwise
  /// the image generated by [imageGenerator] is returned.
  ///
  /// If the [imageGenerator] is used, the resulting [Image] is stored with
  /// [name] in the cache.
  Future<Image> fetchOrGenerate(
    String name,
    Future<Image> Function() imageGenerator,
  ) {
    return (_assets[name] ??= _ImageAsset.future(imageGenerator()))
        .retrieveAsync();
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
    final manifestContent = await bundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final imagePaths = manifestMap.keys.where((path) {
      return path.startsWith(_prefix) && path.toLowerCase().contains(pattern);
    }).map((path) => path.replaceFirst(_prefix, ''));
    return loadAll(imagePaths.toList());
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(String key) => _assets.containsKey(key);

  String? findKeyForImage(Image image) {
    return _assets.keys.firstWhere(
      (k) => _assets[k]?.image?.isCloneOf(image) ?? false,
    );
  }

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  Future<Image> fromBase64(String key, String base64) {
    return (_assets[key] ??= _ImageAsset.future(_fetchFromBase64(base64)))
        .retrieveAsync();
  }

  Future<Image> _fetchFromBase64(String base64Data) {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final bytes = base64.decode(data);
    return decodeImageFromList(bytes);
  }

  Future<Image> _fetchToMemory(String name) async {
    final data = await bundle.load('$_prefix$name');
    final bytes = Uint8List.view(data.buffer);
    return decodeImageFromList(bytes);
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
