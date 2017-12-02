import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:audioplayers/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

class Audio {
  Map<String, File> loadedFiles = new Map();

  void clear(String fileName) {
    loadedFiles.remove(fileName);
  }

  void clearCache() {
    loadedFiles.clear();
  }

  void disableLog() {
    AudioPlayer.logEnabled = false;
  }

  Future<ByteData> _fetchAsset(String fileName) async {
    return await rootBundle.load('assets/audio/' + fileName);
  }

  Future<File> _fetchToMemory(String fileName) async {
    final file = new File('${(await getTemporaryDirectory()).path}/$fileName');
    return await file.writeAsBytes((await _fetchAsset(fileName)).buffer.asUint8List());
  }

  Future<File> load(String fileName) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await _fetchToMemory(fileName);
    }
    return loadedFiles[fileName];
  }

  Future<int> play(String fileName) async {
    File file = await load(fileName);
    return await new AudioPlayer().play(file.path, isLocal: true);
  }

  Future<int> loop(String fileName) async {
    File file = await load(fileName);
    AudioPlayer player = new AudioPlayer();
    player.setCompletionHandler(() => player.play(file.path, isLocal: true));
    return await player.play(file.path, isLocal: true);
  }

}
