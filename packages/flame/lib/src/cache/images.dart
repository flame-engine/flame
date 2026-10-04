import 'dart:async';
import 'dart:convert' show base64;
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flame/src/flame.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

/// A cache of decoded [Image]s, keyed by name.
///
/// The cache owns every image in it and disposes of an image when it is
/// removed, either explicitly through [clear] and [clearCache] or through
/// eviction.
///
/// ## Eviction
///
/// Images can be evicted automatically once they are no longer used, so that
/// a game that loads images as it goes does not grow its memory usage without
/// bound. Eviction is opt-in: with no [maxSizeBytes] set and no calls to
/// [evictUnused], the cache keeps every image until it is cleared.
///
/// The cache knows which images are in use through reference counting. Every
/// component that renders an image retains it with [retain] while it is
/// mounted and releases it with [release] when it is removed, which the Flame
/// components do through the `ImageRetainer` mixin. An image with no retainers
/// is eligible for eviction once [gracePeriod] has passed since it was last
/// loaded, fetched or released. The grace period covers the gap between
/// loading an image, typically in `onLoad`, and the component that uses it
/// being mounted.
///
/// Eviction runs when [evictUnused] is called, and automatically when a load
/// pushes the cache over [maxSizeBytes], in which case the least recently used
/// eligible images are disposed until the cache fits in its budget again.
///
/// An evicted image is gone from the cache, so with eviction enabled obtain
/// images with [load] rather than [fromCache], since [load] decodes the image
/// again when it is missing and [fromCache] fails. Images that your own code
/// keeps outside of a retaining component must be retained manually.
class Images({AssetBundle? bundle, int? maxSizeBytes}) {
  static final Expando<_ImageAsset> _assetsByImage = Expando<_ImageAsset>(
    'Images',
  );

  final Map<String, _ImageAsset> _assets = {};

  final Set<String> _evictedKeys = {};

  /// The [AssetBundle] from which images are loaded.
  /// defaults to [Flame.bundle].
  AssetBundle bundle = bundle ?? Flame.bundle;

  int? _maxSizeBytes = maxSizeBytes;

  /// The soft upper bound, in bytes, for the images held by this cache.
  ///
  /// When a load pushes the cache over this budget, eligible images are
  /// disposed in least recently used order until the cache fits again. Images
  /// that are retained, or that were used within [gracePeriod], are never
  /// evicted, so the cache can exceed the budget while they are needed.
  ///
  /// When `null`, which is the default, no automatic eviction happens.
  int? get maxSizeBytes => _maxSizeBytes;

  set maxSizeBytes(int? value) {
    _maxSizeBytes = value;
    _enforceBudget();
  }

  /// How long an image stays in the cache after it was last loaded, fetched,
  /// retained or released before it becomes eligible for eviction.
  ///
  /// This covers the gap between loading an image and mounting the component
  /// that retains it. Raise it if a component loads many images one after the
  /// other before it is mounted.
  Duration gracePeriod = const Duration(seconds: 5);

  /// The estimated size, in bytes, of all the loaded images in the cache.
  ///
  /// Every image is estimated as four bytes per pixel, which is what the
  /// decoded image occupies in memory. Images that are still loading do not
  /// count.
  int get sizeBytes {
    var total = 0;
    for (final asset in _assets.values) {
      total += asset.sizeBytes;
    }
    return total;
  }

  /// Returns the cache that [image] was loaded into, or `null` if the image
  /// does not belong to any cache.
  ///
  /// Only the image object that the cache handed out is recognized, a clone of
  /// it is not.
  static Images? ownerOf(Image image) {
    final asset = _assetsByImage[image];
    if (asset == null || !asset.owner._isLive(asset)) {
      return null;
    }
    return asset.owner;
  }

  /// Marks [image] as in use, which protects it from eviction until it is
  /// released with [release] as many times as it was retained.
  ///
  /// This is a no-op when [image] does not belong to this cache. A clone of a
  /// cached image, made with `Image.clone`, retains the cached original.
  void retain(Image image) {
    final asset = _assetFor(image);
    if (asset == null) {
      return;
    }
    asset.refCount++;
    asset.lastUsed = clock.now();
  }

  /// Undoes one call to [retain] for [image].
  ///
  /// This is a no-op when [image] does not belong to this cache, which is also
  /// the case when it was cleared from the cache since it was retained.
  void release(Image image) {
    final asset = _assetFor(image);
    if (asset == null) {
      return;
    }
    assert(
      asset.refCount > 0,
      'Tried to release the image "${asset.key}" more times than it was '
      'retained',
    );
    if (asset.refCount > 0) {
      asset.refCount--;
    }
    asset.lastUsed = clock.now();
  }

  /// The number of times that the image under [key] is currently retained.
  ///
  /// Returns `0` when there is no such image in the cache.
  int retainCount(String key) => _assets[key]?.refCount ?? 0;

  /// The estimated size, in bytes, of the image under [key].
  ///
  /// Returns `0` when there is no such image in the cache or when it is still
  /// loading.
  int sizeBytesOf(String key) => _assets[key]?.sizeBytes ?? 0;

  /// Disposes every image in the cache that is not retained and has not been
  /// loaded, fetched, retained or released within [gracePeriod].
  ///
  /// Returns the estimated number of bytes that were freed.
  int evictUnused() {
    var freed = 0;
    for (final asset in _evictionCandidates()) {
      freed += asset.sizeBytes;
      _evict(asset);
    }
    return freed;
  }

  /// Adds the [image] into the cache under the key [name].
  ///
  /// The cache will assume the ownership of the [image], and will properly
  /// dispose of it at the end.
  void add(String name, Image image) {
    _assets[name]?.dispose();
    _assets[name] = _ImageAsset.fromImage(this, name, image);
    _enforceBudget();
  }

  /// Transform the base64 encoded image into an [Image] and adds it into the
  /// cache.
  Future<void> addFromBase64Data(String name, String base64Data) async {
    _assets[name]?.dispose();
    final image = await _fetchFromBase64(base64Data);
    _assets[name] = _ImageAsset.fromImage(this, name, image);
    _enforceBudget();
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
    return _fetch(name, imageGenerator);
  }

  /// Removes the image [name] from the cache.
  ///
  /// No error is raised if the image [name] is not present in the cache.
  ///
  /// This calls [Image.dispose], so make sure that you don't use the previously
  /// cached image once it is cleared (removed) from the cache. The image is
  /// removed even if it is retained.
  void clear(String name) {
    final removedAsset = _assets.remove(name);
    removedAsset?.dispose();
  }

  /// Removes all cached images.
  ///
  /// This calls [Image.dispose] for all images in the cache, so make sure that
  /// you don't use any of the previously cached images once [clearCache] has
  /// been called. Retained images are removed too.
  void clearCache() {
    _assets.forEach((_, asset) => asset.dispose());
    _assets.clear();
    _evictedKeys.clear();
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
      _evictedKeys.contains(name)
          ? 'Tried to access an image "$name" that has been evicted from the '
                'cache. Use load() to get images when eviction is enabled, '
                'or retain() the image while you keep a reference to it'
          : 'Tried to access an image "$name" that does not exist in the '
                'cache. Make sure to load() an image before accessing it',
    );
    assert(
      asset!.image != null,
      'Tried to access an image "$name" before it was loaded. Make sure to '
      'await the future from load() before using this method',
    );
    asset!.lastUsed = clock.now();
    return asset.image!;
  }

  /// Loads the image at [fileName] into the cache.
  ///
  /// The [fileName] is the full path of the asset, exactly as declared in the
  /// `pubspec.yaml`, for example `assets/images/player.png`. When a [package]
  /// is given, the path is resolved relative to that package's assets.
  ///
  /// By default the key in the cache is the resolved path, if another key is
  /// desired, specify the optional [key] argument.
  Future<Image> load(String fileName, {String? key, String? package}) {
    final path = resolvePath(fileName, package);
    return _fetch(key ?? path, () => _fetchToMemory(path));
  }

  /// Loads all images with the specified [fileNames] into the cache.
  Future<List<Image>> loadAll(List<String> fileNames) {
    return Future.wait(fileNames.map(load));
  }

  /// Loads every image found under [directory] into the cache.
  ///
  /// The [directory] must be empty, or end with a "/". An empty [directory]
  /// matches every asset in the bundle.
  Future<List<Image>> loadAllImages({required String directory}) {
    return loadAllFromPattern(
      RegExp(
        r'\.(png|jpg|jpeg|svg|gif|webp|bmp|wbmp)$',
        caseSensitive: false,
      ),
      directory: directory,
    );
  }

  /// Loads all images under [directory] that match the specified pattern.
  ///
  /// Images are cached under their full path, as listed in the asset manifest.
  Future<List<Image>> loadAllFromPattern(
    Pattern pattern, {
    required String directory,
  }) async {
    assert(
      directory.isEmpty || directory.endsWith('/'),
      'directory must be empty or end with a "/"',
    );
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final imagePaths = manifest.listAssets().where((path) {
      return path.startsWith(directory) && path.toLowerCase().contains(pattern);
    });
    final images = await loadAll(imagePaths.toList());
    return images;
  }

  /// Whether the cache contains the specified [key] or not.
  bool containsKey(String key) => _assets.containsKey(key);

  /// Returns the list of keys in the cache.
  List<String> get keys => _assets.keys.toList();

  String? findKeyForImage(Image image) {
    final asset = _assetsByImage[image];
    if (asset != null && _isLive(asset)) {
      return asset.key;
    }
    return _assets.keys.firstWhere(
      (k) => _assets[k]?.image?.isCloneOf(image) ?? false,
    );
  }

  /// Waits until all currently pending image loading operations complete.
  Future<void> ready() {
    return Future.wait(_assets.values.map((asset) => asset.retrieveAsync()));
  }

  Future<Image> fromBase64(String key, String base64) {
    return _fetch(key, () => _fetchFromBase64(base64));
  }

  /// Resolves [fileName] to the path it is loaded from, and cached under, when
  /// it belongs to [package].
  static String resolvePath(String fileName, String? package) =>
      package == null ? fileName : 'packages/$package/$fileName';

  Future<Image> _fetch(String key, Future<Image> Function() generator) {
    final existing = _assets[key];
    if (existing != null) {
      existing.lastUsed = clock.now();
      return existing.retrieveAsync();
    }
    _evictedKeys.remove(key);
    final asset = _assets[key] = _ImageAsset.future(this, key, generator());
    return asset.retrieveAsync();
  }

  Future<Image> _fetchFromBase64(String base64Data) {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final bytes = base64.decode(data);
    return decodeImageFromList(bytes);
  }

  Future<Image> _fetchToMemory(String path) async {
    final data = await bundle.load(path);
    final bytes = Uint8List.view(data.buffer);
    final image = await decodeImageFromList(bytes);
    return image;
  }

  /// Whether [asset] is the entry that the cache currently holds for its key.
  bool _isLive(_ImageAsset asset) => identical(_assets[asset.key], asset);

  /// Finds the entry that holds [image], or the original that [image] is a
  /// clone of.
  _ImageAsset? _assetFor(Image image) {
    final asset = _assetsByImage[image];
    if (asset != null) {
      return asset.owner == this && _isLive(asset) ? asset : null;
    }
    for (final candidate in _assets.values) {
      final candidateImage = candidate.image;
      if (candidateImage != null && image.isCloneOf(candidateImage)) {
        return candidate;
      }
    }
    return null;
  }

  void _onImageLoaded(_ImageAsset asset) {
    if (!_isLive(asset)) {
      return;
    }
    _enforceBudget();
  }

  List<_ImageAsset> _evictionCandidates() {
    final now = clock.now();
    return _assets.values.where((asset) {
      return asset.refCount == 0 &&
          asset.image != null &&
          now.difference(asset.lastUsed) >= gracePeriod;
    }).toList();
  }

  void _enforceBudget() {
    final budget = _maxSizeBytes;
    if (budget == null) {
      return;
    }
    var size = sizeBytes;
    if (size <= budget) {
      return;
    }
    final candidates = _evictionCandidates()
      ..sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
    for (final asset in candidates) {
      if (size <= budget) {
        break;
      }
      size -= asset.sizeBytes;
      _evict(asset);
    }
  }

  void _evict(_ImageAsset asset) {
    _assets.remove(asset.key);
    _evictedKeys.add(asset.key);
    asset.dispose();
  }
}

/// Individual entry in the [Images] cache.
///
/// This class owns the [Image] object, which can be disposed of using the
/// [dispose] method.
class _ImageAsset {
  _ImageAsset.future(this.owner, this.key, Future<Image> future)
    : _future = future {
    _future!.then((image) {
      if (_disposed) {
        return;
      }
      _image = image;
      _future = null;
      _track();
      owner._onImageLoaded(this);
    });
  }

  _ImageAsset.fromImage(this.owner, this.key, Image image) : _image = image {
    _track();
  }

  final Images owner;
  final String key;

  int refCount = 0;
  DateTime lastUsed = clock.now();

  Image? get image => _image;
  Image? _image;

  Future<Image>? _future;

  int get sizeBytes {
    final image = _image;
    if (image == null) {
      return 0;
    }
    return image.width * image.height * 4;
  }

  Future<Image> retrieveAsync() => _future ?? Future.value(_image);

  void _track() {
    Images._assetsByImage[_image!] = this;
    lastUsed = clock.now();
  }

  bool _disposed = false;

  /// Properly dispose of an image asset.
  void dispose() {
    _disposed = true;
    if (_image != null) {
      Images._assetsByImage[_image!] = null;
      _image!.dispose();
      _image = null;
    }
    if (_future != null) {
      _future!.then((image) => image.dispose());
      _future = null;
    }
  }
}
