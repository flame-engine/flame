import 'dart:convert';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flutter/services.dart' show AssetBundle;

/// A class that loads, and caches files.
///
/// Files are addressed by their full path, exactly as declared in the
/// `pubspec.yaml`, for example `assets/levels/level1.json`.
class AssetsCache {
  AssetsCache({AssetBundle? bundle}) : bundle = bundle ?? Flame.bundle;

  /// The [AssetBundle] from which assets are loaded.
  /// defaults to [Flame.bundle].
  AssetBundle bundle;

  final Map<String, _Asset<dynamic>> _files = {};

  /// Removes the file from the cache.
  void clear(String file) {
    _files.remove(file);
  }

  /// Removes all the files from the cache.
  void clearCache() {
    _files.clear();
  }

  /// Returns the number of files in the cache.
  int get cacheCount => _files.length;

  /// Reads a file from the assets.
  ///
  /// The [fileName] is the full path of the asset. When a [package] is given,
  /// the path is resolved relative to that package's assets.
  Future<String> readFile(String fileName, {String? package}) async {
    final path = _resolve(fileName, package);
    if (!_files.containsKey(path)) {
      _files[path] = await _readFile(path);
    }
    assert(
      _files[path] is _StringAsset,
      '"$path" was previously loaded as a binary file',
    );
    return (_files[path]! as _StringAsset).value;
  }

  /// Reads a binary file from the assets.
  ///
  /// The [fileName] is the full path of the asset. When a [package] is given,
  /// the path is resolved relative to that package's assets.
  Future<Uint8List> readBinaryFile(String fileName, {String? package}) async {
    final path = _resolve(fileName, package);
    if (!_files.containsKey(path)) {
      _files[path] = await _readBinary(path);
    }
    assert(
      _files[path] is _BinaryAsset,
      '"$path" was previously loaded as a text file',
    );
    return (_files[path]! as _BinaryAsset).value;
  }

  /// Reads a json file from the assets.
  ///
  /// The [fileName] is the full path of the asset. When a [package] is given,
  /// the path is resolved relative to that package's assets.
  Future<Map<String, dynamic>> readJson(
    String fileName, {
    String? package,
  }) async {
    final path = _resolve(fileName, package);
    if (!_files.containsKey(path)) {
      _files[path] = await _readJson(path);
    }
    assert(
      _files[path] is _JsonAsset,
      '"$path" was previously loaded as a different type',
    );
    return (_files[path]! as _JsonAsset).value;
  }

  static String _resolve(String fileName, String? package) =>
      package == null ? fileName : 'packages/$package/$fileName';

  Future<_StringAsset> _readFile(String path) async {
    final string = await bundle.loadString(path);
    return _StringAsset(string);
  }

  Future<_BinaryAsset> _readBinary(String path) async {
    final data = await bundle.load(path);
    final bytes = Uint8List.view(data.buffer);
    return _BinaryAsset(bytes);
  }

  Future<_JsonAsset> _readJson(String path) async {
    final string = await _readFile(path);
    final json = jsonDecode(string.value) as Map<String, dynamic>;
    return _JsonAsset(json);
  }

  /// This method provides synchronous access to cached assets, similar to
  /// [AssetsCache.fromCache].
  T fromCache<T>(String fileName) {
    final asset = _files[fileName];
    assert(
      asset != null,
      'Tried to access an asset "$fileName" that does not exist in the cache. '
      'Make sure to load the asset using readFile(), readBinaryFile(), or '
      'readJson() before accessing it with fromCache()',
    );
    assert(
      asset!.value is T,
      'Tried to access asset "$fileName" as type $T, but it was loaded as '
      '${asset.value.runtimeType}. Make sure to use the correct type when '
      'calling fromCache<T>()',
    );

    return asset!.value as T;
  }
}

sealed class _Asset<T> {
  T value;
  _Asset(this.value);
}

class _StringAsset extends _Asset<String> {
  _StringAsset(super.value);
}

class _BinaryAsset extends _Asset<Uint8List> {
  _BinaryAsset(super.value);
}

class _JsonAsset extends _Asset<Map<String, dynamic>> {
  _JsonAsset(super.value);
}
