import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class FlameAudio {
  AudioCache audioCache = AudioCache(prefix: 'audio/');

  Future<AudioPlayer> play(String file) {
    return audioCache.play(file);
  }

  Future<AudioPlayer> loop(String file) {
    return audioCache.loop(file);
  }

  Future<AudioPlayer> playSfx(String file) {
    return audioCache.play(file, mode: PlayerMode.LOW_LATENCY);
  }
}
