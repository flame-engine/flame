import 'dart:convert';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flutter/services.dart' show AssetBundle;

/// A class that loads, and caches files.
///
/// It automatically looks for files in the `assets` directory.
class AssetsCache {
  AssetsCache({
    this.prefix = 'assets/',
    AssetBundle? bundle,
  }) : bundle = bundle ?? Flame.bundle;

  /// The [AssetBundle] from which assets are loaded.
  /// defaults to [Flame.bundle].
  AssetBundle bundle;

  String prefix;
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

  /// Reads a file from assets folder.
  Future<String> readFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readFile(fileName);
    }
    assert(
      _files[fileName] is _StringAsset,
      '"$fileName" was previously loaded as a binary file',
    );
    return (_files[fileName]! as _StringAsset).value;
  }

  /// Reads a binary file from assets folder.
  Future<Uint8List> readBinaryFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readBinary(fileName);
    }
    assert(
      _files[fileName] is _BinaryAsset,
      '"$fileName" was previously loaded as a text file',
    );
    return (_files[fileName]! as _BinaryAsset).value;
  }

  /// Reads a json file from the assets folder.
  Future<Map<String, dynamic>> readJson(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readJson(fileName);
    }
    assert(
      _files[fileName] is _JsonAsset,
      '"$fileName" was previously loaded as a different type',
    );
    return (_files[fileName]! as _JsonAsset).value;
  }

  Future<_StringAsset> _readFile(String fileName) async {
    final string = await bundle.loadString('$prefix$fileName');
    return _StringAsset(string);
  }

  Future<_BinaryAsset> _readBinary(String fileName) async {
    final data = await bundle.load('$prefix$fileName');
    final bytes = Uint8List.view(data.buffer);
    return _BinaryAsset(bytes);
  }

  Future<_JsonAsset> _readJson(String fileName) async {
    final string = await bundle.loadString('$prefix$fileName');
    final json = jsonDecode(string) as Map<String, dynamic>;
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
