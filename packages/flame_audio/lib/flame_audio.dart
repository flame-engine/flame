import 'package:audioplayers/audioplayers.dart';

import 'package:flame_audio/bgm.dart';

export 'package:audioplayers/audioplayers.dart';

/// A typedef for a function that creates an [AudioCache] instance.
typedef AudioCacheFactory = AudioCache Function({required String prefix});

/// A typedef for a function that creates a [Bgm] instance.
typedef BgmFactory = Bgm Function({required AudioCache audioCache});

/// This utility class holds static references to some global audio objects.
///
/// You can use as a helper to very simply play a sound or a background music.
/// Alternatively you can create your own instances and control them yourself.
class FlameAudio {
  /// The factory used to create the global [AudioCache] instance.
  ///
  /// Useful to override the default [AudioCache] constructor in testing
  /// or edge cases where the developer needs control on how [AudioCache]
  /// are created.
  static AudioCacheFactory audioCacheFactory = AudioCache.new;

  /// The factory used to create the global [Bgm] instance.
  ///
  /// Useful to override the default [Bgm] constructor in testing
  /// or edge cases where the developer needs control on how [Bgm]
  /// are created.
  static BgmFactory bgmFactory = Bgm.new;

  /// Access a shared instance of the [AudioCache] class.
  static late AudioCache audioCache = audioCacheFactory(
    prefix: 'assets/audio/',
  );

  /// Access a shared instance of the [Bgm] class.
  ///
  /// This will use the same global audio cache from [FlameAudio].
  static late final Bgm bgm = bgmFactory(audioCache: audioCache);

  /// Updates the prefix in the global [AudioCache] and [bgm] instances.
  static void updatePrefix(String prefix) {
    audioCache.prefix = prefix;
    bgm.audioPlayer.audioCache.prefix = prefix;
  }

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

  /// Creates a new Audio Pool using Flame's global Audio Cache.
  static Future<AudioPool> createPool(
    String sound, {
    required int maxPlayers,
    int minPlayers = 1,
  }) {
    return AudioPool.create(
      source: AssetSource(sound),
      audioCache: audioCache,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }
}
