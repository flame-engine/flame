import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

/// A class that loads, and cache files
///
/// it automatically looks for files on the assets folder
class AssetsCache {
  final Map<String, _Asset> _files = {};

  /// Removes the file from the cache
  void clear(String file) {
    _files.remove(file);
  }

  /// Removes all the files from the cache
  void clearCache() {
    _files.clear();
  }

  /// Reads a file from assets folder
  Future<String> readFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readFile(fileName);
    }

    assert(_files[fileName] is _StringAsset,
        '"${fileName}" is not a String Asset');

    return _files[fileName].value;
  }

  /// Reads a binary file from assets folder
  Future<List<int>> readBinaryFile(String fileName) async {
    if (!_files.containsKey(fileName)) {
      _files[fileName] = await _readBinary(fileName);
    }

    assert(_files[fileName] is _BinaryAsset,
        '"${fileName}" is not a Binary Asset');

    return _files[fileName].value;
  }

  Future<_StringAsset> _readFile(String fileName) async {
    final string = await rootBundle.loadString('assets/$fileName');
    return _StringAsset()..value = string;
  }

  Future<_BinaryAsset> _readBinary(String fileName) async {
    final data = await rootBundle.load('assets/$fileName');
    final Uint8List list = Uint8List.view(data.buffer);

    final bytes = List.from(list).cast<int>();
    return _BinaryAsset()..value = bytes;
  }
}

class _Asset<T> {
  T value;
}

class _StringAsset extends _Asset<String> {}

class _BinaryAsset extends _Asset<List<int>> {}
