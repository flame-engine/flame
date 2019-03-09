import 'package:flutter/services.dart' show rootBundle;

class AssetsCache {
  Map<String, String> textFiles = {};

  void clear(String file) {
    textFiles.remove(file);
  }

  void clearCache() {
    textFiles.clear();
  }

  Future<String> readFile(String fileName) async {
    if (!textFiles.containsKey(fileName)) {
      textFiles[fileName] = await _readFile(fileName);
    }

    return textFiles[fileName];
  }

  Future<String> _readFile(String fileName) async {
    return await rootBundle.loadString("assets/" + fileName);
  }
}
