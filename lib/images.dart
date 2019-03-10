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

  Future<Image> load(String fileName) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await _fetchToMemory(fileName);
    }
    return loadedFiles[fileName];
  }

  Future<Image> _fetchToMemory(String name) async {
    ByteData data = await Flame.bundle.load('assets/images/' + name);
    Uint8List bytes = Uint8List.view(data.buffer);
    Completer<Image> completer = Completer();
    decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }
}
