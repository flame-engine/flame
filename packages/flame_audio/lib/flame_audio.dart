import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/audio_pool.dart';

import 'package:flame_audio/bgm.dart';

/// This utility class holds static references to some global audio objects.
///
/// You can use as a helper to very simply play a sound or a background music.
/// Alternatively you can create your own instances and control them yourself.
class FlameAudio {
  /// Access a shared instance of the [AudioCache] class.
  static AudioCache audioCache = AudioCache(prefix: 'assets/audio/');

  static Future<AudioPlayer> _preparePlayer(
    String file,
    double volume,
    ReleaseMode releaseMode,
    PlayerMode playerMode,
  ) async {
    final player = AudioPlayer()..audioCache = audioCache;
    await player.setReleaseMode(releaseMode);
    await player.play(
      AssetSource(file),
      volume: volume,
      mode: playerMode,
    );
    return player;
  }

  /// Plays a single run of the given [file], with a given [volume].
  static Future<AudioPlayer> play(String file, {double volume = 1.0}) async {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.release,
      PlayerMode.lowLatency,
    );
  }

  /// Plays, and keeps looping the given [file].
  static Future<AudioPlayer> loop(String file, {double volume = 1.0}) async {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.loop,
      PlayerMode.lowLatency,
    );
  }

  /// Plays a single run of the given file [file]
  /// This method supports long audio files
  static Future<AudioPlayer> playLongAudio(String file, {double volume = 1.0}) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.release,
      PlayerMode.mediaPlayer,
    );
  }

  /// Plays, and keep looping the given [file]
  /// This method supports long audio files
  ///
  /// NOTE: Length audio files on Android have an audio gap between loop
  /// iterations, this happens due to limitations on Android's native media
  /// player features. If you need a gapless loop, prefer the loop method.
  static Future<AudioPlayer> loopLongAudio(String file, {double volume = 1.0}) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.loop,
      PlayerMode.mediaPlayer,
    );
  }

  /// Access a shared instance of the [Bgm] class.
  ///
  /// This will use the same global audio cache from [FlameAudio].
  static late final Bgm bgm = Bgm(audioCache: audioCache);

  /// Creates a new Audio Pool using Flame's global Audio Cache.
  static Future<AudioPool> createPool(
    String sound, {
    int minPlayers = 1,
    required int maxPlayers,
  }) {
    return AudioPool.create(
      sound,
      audioCache: audioCache,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }
}
