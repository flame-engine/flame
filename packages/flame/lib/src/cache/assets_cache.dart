import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

/// A class that loads, and caches files.
///
/// It automatically looks for files in the `assets` directory.
class AssetsCache {
  final String prefix;
  final Map<String, _Asset> _files = {};

  AssetsCache({this.prefix = 'assets/'});

  /// Removes the file from the cache.
  void clear(String file) {
    _files.remove(file);
  }

  /// Removes all the files from the cache.
  void clearCache() {
    _files.clear();
  }

  /// Reads a file from assets folder.
  Future<String> readFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readFile(fileName);
    }

    assert(
      _files[fileName] is _StringAsset,
      '"$fileName" is not a String Asset',
    );

    return _files[fileName]!.value as String;
  }

  /// Reads a binary file from assets folder.
  Future<List<int>> readBinaryFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readBinary(fileName);
    }

    assert(
      _files[fileName] is _BinaryAsset,
      '"$fileName" is not a Binary Asset',
    );

    return _files[fileName]!.value as List<int>;
  }

  /// Reads a json file from the assets folder.
  Future<Map<String, dynamic>> readJson(String fileName) async {
    final content = await readFile(fileName);
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<_StringAsset> _readFile(String fileName) async {
    final string = await rootBundle.loadString('$prefix$fileName');
    return _StringAsset(string);
  }

  Future<_BinaryAsset> _readBinary(String fileName) async {
    final data = await rootBundle.load('$prefix$fileName');
    final list = Uint8List.view(data.buffer);

    final bytes = List<int>.from(list);
    return _BinaryAsset(bytes);
  }
}

class _Asset<T> {
  T value;
  _Asset(this.value);
}

class _StringAsset extends _Asset<String> {
  _StringAsset(super.value);
}

class _BinaryAsset extends _Asset<List<int>> {
  _BinaryAsset(super.value);
}
