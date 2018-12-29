import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/flame.dart';

class Images {
  Map<String, Image> loadedFiles = {};

  void clear(String fileName) {
    loadedFiles.remove(fileName);
  }

  void clearCache() {
    loadedFiles.clear();
  }

  Future<List<Image>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  Future<Image> load(String fileName, {String prefix = 'images/'}) async {
    var path = prefix + fileName;
    if (!loadedFiles.containsKey(path)) {
      loadedFiles[path] = await _fetchToMemory(path);
    }
    return loadedFiles[path];
  }

  Future<Image> _fetchToMemory(String name) async {
    ByteData data = await Flame.bundle.load('assets/' + name);
    Uint8List bytes = new Uint8List.view(data.buffer);
    Completer<Image> completer = new Completer();
    decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }
}
