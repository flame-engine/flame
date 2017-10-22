import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:audioplayers/audioplayer.dart';
import 'package:path_provider/path_provider.dart';

class Audio {

  Map<String, File> loadedFiles = new Map();

  Future<ByteData> _loadAsset(String fileName) async {
    return await rootBundle.load('assets/audio/' + fileName);
  }

  Future<File> load(String fileName) async {
    final file = new File('${(await getTemporaryDirectory()).path}/${fileName}');
    return await file.writeAsBytes((await _loadAsset(fileName)).buffer.asUint8List());
  }

  Future<int> play(String fileName) async {
    if (!loadedFiles.containsKey(fileName)) {
      loadedFiles[fileName] = await load(fileName);
    }
    AudioPlayer audioPlayer = new AudioPlayer();
    return await audioPlayer.play(loadedFiles[fileName].path, isLocal: true);
  }
}