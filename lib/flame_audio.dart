import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

/// Handles flame audio functions
class FlameAudio {
  AudioCache audioCache = AudioCache(prefix: 'audio/');

  /// Plays a single run of the given [file]
  Future<AudioPlayer> play(String file, {volume = 1.0}) {
    return audioCache.play(file, volume: volume, mode: PlayerMode.LOW_LATENCY);
  }

  /// Plays, and keep looping the given [file]
  Future<AudioPlayer> loop(String file, {volume = 1.0}) {
    return audioCache.loop(file, volume: volume, mode: PlayerMode.LOW_LATENCY);
  }

  /// Plays a single run of the given file [file]
  /// This method supports long audio files
  Future<AudioPlayer> playLongAudio(String file, {volume = 1.0}) {
    return audioCache.play(file, volume: volume);
  }

  /// Plays, and keep looping the given [file]
  /// This method supports long audio files
  ///
  /// NOTE: Length audio files on Android have an audio gap between loop iterations, this happens due to limitations on Android's native media player features, if you need a gapless loop, prefer the loop method
  Future<AudioPlayer> loopLongAudio(String file, {volume = 1.0}) {
    return audioCache.play(file, volume: volume);
  }

  /// Prefetch an audio in the cache
  Future<File> load(String file) {
    return audioCache.load(file);
  }

  /// Prefetch a list of audios in the cache
  Future<List<File>> loadAll(List<String> files) {
    return audioCache.loadAll(files);
  }

  /// Clears the file in the cache
  void clear(String file) {
    audioCache.clear(file);
  }

  /// Clears all the audios in the cache
  void clearAll() {
    audioCache.clearCache();
  }

  /// Disables audio related logs
  void disableLog() {
    audioCache.disableLog();
  }
}
