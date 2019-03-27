import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

/// Handles flame audio functions
class FlameAudio {
  AudioCache audioCache = AudioCache(prefix: 'audio/');

  /// Plays the given [file] as a music
  Future<AudioPlayer> playMusic(String file, { volume = 1.0 }) {
    return audioCache.play(file, volume: volume);
  }

  /// Plays, and keep looping the given [file] as a music
  Future<AudioPlayer> loopMusic(String file, { volume = 1.0 }) {
    return audioCache.loop(file, volume: volume);
  }

  /// Plays the given [file] as a sound effect
  Future<AudioPlayer> playSfx(String file, { volume = 1.0 }) {
    return audioCache.play(file, volume: volume, mode: PlayerMode.LOW_LATENCY);
  }

  /// Prefetch an audio in the cache
  Future<void> load(String file) async {
    await audioCache.load(file);
  }
 
  /// Prefetch a list of audios in the cache
  Future<void> loadAll(List<String> files) async {
    await audioCache.loadAll(files);
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
