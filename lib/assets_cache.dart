import 'package:flutter/services.dart' show rootBundle;

/// A class that loads, and cache files
///
/// it automatically looks for files on the assets folder
class AssetsCache {
  Map<String, String> textFiles = {};

  /// Removes the file from the cache
  void clear(String file) {
    textFiles.remove(file);
  }

  /// Removes all the files from the cache
  void clearCache() {
    textFiles.clear();
  }

  /// Reads a file from assets folder
  Future<String> readFile(String fileName) async {
    if (!textFiles.containsKey(fileName)) {
      textFiles[fileName] = await _readFile(fileName);
    }

    return textFiles[fileName];
  }

  Future<String> _readFile(String fileName) async {
    return await rootBundle.loadString('assets/$fileName');
  }
}
