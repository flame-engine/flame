import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert' show base64;

import 'package:flame/flame.dart';

class Images {
  final Map<String, _ImageAssetLoader> _loadedFiles = {};

  void clear(String fileName) {
    _loadedFiles.remove(fileName);
  }

  void clearCache() {
    _loadedFiles.clear();
  }

  Image fromCache(String fileName) {
    final image = _loadedFiles[fileName];
    assert(image?.loadedImage != null,
        'Tried to access an inexistent entry on cache "$fileName"');
    return image.loadedImage;
  }

  Future<List<Image>> loadAll(List<String> fileNames) async {
    return Future.wait(fileNames.map(load));
  }

  Future<Image> load(String fileName) async {
    if (!_loadedFiles.containsKey(fileName)) {
      _loadedFiles[fileName] = _ImageAssetLoader(_fetchToMemory(fileName));
    }
    return await _loadedFiles[fileName].retreive();
  }

  Future<Image> fromBase64(String fileName, String base64) async {
    if (!_loadedFiles.containsKey(fileName)) {
      _loadedFiles[fileName] = _ImageAssetLoader(_fetchFromBase64(base64));
    }
    return await _loadedFiles[fileName].retreive();
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

class _ImageAssetLoader {
  _ImageAssetLoader(this.future);

  Image loadedImage;
  Future<Image> future;

  Future<Image> retreive() async {
    loadedImage ??= await future;

    return loadedImage;
  }
}
