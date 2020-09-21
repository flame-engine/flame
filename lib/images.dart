import 'dart:async';
import 'dart:convert' show base64;
import 'dart:typed_data';
import 'dart:ui';

import 'flame.dart';

class Images {
  Map<String, ImageAssetLoader> loadedFiles = {};

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
      loadedFiles[fileName] = ImageAssetLoader(_fetchToMemory(fileName));
    }
    return await loadedFiles[fileName].retreive();
  }

  Future<Image> fromBase64(String fileName, String base64) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = ImageAssetLoader(_fetchFromBase64(base64));
    }
    return await loadedFiles[fileName].retreive();
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

class ImageAssetLoader {
  ImageAssetLoader(this.future);

  Image loadedImage;
  Future<Image> future;

  Future<Image> retreive() async {
    loadedImage ??= await future;

    return loadedImage;
  }
}
