import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert' show base64;

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

  Future<Image> fromBase64(String fileName, String base64) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await _fetchFromBase64(base64);
    }
    return loadedFiles[fileName];
  }

  Future<Image> _fetchFromBase64(String base64Data) async {
    final data = base64Data.substring(base64Data.indexOf(',') + 1);
    final Uint8List bytes = base64.decode(data);
    return _loadBytes(bytes);
  }

  Future<Image> _fetchToMemory(String name) async {
    final ByteData data = await Flame.bundle.load('assets/images/' + name);
    final Uint8List bytes = Uint8List.view(data.buffer);
    return _loadBytes(bytes);
  }

  Future<Image> _loadBytes(Uint8List bytes) {
    final Completer<Image> completer = Completer();
    decodeImageFromList(bytes, (image) => completer.complete(image));
    return completer.future;
  }
}
