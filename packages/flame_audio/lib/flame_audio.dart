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
  static AudioCache audioCache = audioCacheFactory(
    prefix: 'assets/audio/',
  );

  /// Access a shared instance of the [Bgm] class.
  ///
  /// This will use the same global audio cache from [FlameAudio].
  static final Bgm bgm = bgmFactory(audioCache: audioCache);

  /// Updates the prefix in the global [AudioCache] and [bgm] instances.
  static void updatePrefix(String prefix) {
    audioCache.prefix = prefix;
    bgm.audioPlayer.audioCache.prefix = prefix;
  }

  static Future<AudioPlayer> _preparePlayer(
    String file,
    double volume,
    ReleaseMode releaseMode,
    PlayerMode playerMode, {
    required AudioContext? audioContext,
    String? package,
  }) async {
    final player = AudioPlayer();
    if (package != null) {
      player.audioCache = audioCacheFactory(prefix: '');
    } else {
      player.audioCache = audioCache;
    }
    audioContext ??= _defaultAudioContext;
    await player.setAudioContext(audioContext);
    await player.setReleaseMode(releaseMode);
    final path = package == null ? file : 'packages/$package/${audioCache.prefix}$file';
    await player.play(
      AssetSource(path),
      volume: volume,
      mode: playerMode,
    );
    return player;
  }

  /// Plays a single run of the given [file], with a given [volume].
  static Future<AudioPlayer> play(
    String file, {
    double volume = 1.0,
    AudioContext? audioContext,
    String? package,
  }) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.release,
      PlayerMode.lowLatency,
      audioContext: audioContext,
      package: package,
    );
  }

  /// Plays, and keeps looping the given [file].
  static Future<AudioPlayer> loop(
    String file, {
    double volume = 1.0,
    AudioContext? audioContext,
    String? package,
  }) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.loop,
      PlayerMode.lowLatency,
      audioContext: audioContext,
      package: package,
    );
  }

  /// Plays a single run of the given file [file]
  /// This method supports long audio files
  static Future<AudioPlayer> playLongAudio(
    String file, {
    double volume = 1.0,
    AudioContext? audioContext,
    String? package,
  }) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.release,
      PlayerMode.mediaPlayer,
      audioContext: audioContext,
      package: package,
    );
  }

  /// Plays, and keep looping the given [file]
  /// This method supports long audio files
  ///
  /// NOTE: Length audio files on Android have an audio gap between loop
  /// iterations, this happens due to limitations on Android's native media
  /// player features. If you need a gapless loop, prefer the loop method.
  static Future<AudioPlayer> loopLongAudio(
    String file, {
    double volume = 1.0,
    AudioContext? audioContext,
    String? package,
  }) {
    return _preparePlayer(
      file,
      volume,
      ReleaseMode.loop,
      PlayerMode.mediaPlayer,
      audioContext: audioContext,
      package: package,
    );
  }

  /// Creates a new Audio Pool using Flame's global Audio Cache.
  static Future<AudioPool> createPool(
    String sound, {
    required int maxPlayers,
    int minPlayers = 1,
    AudioContext? audioContext,
    String? package,
  }) async {
    audioContext ??= _defaultAudioContext;
    final path = package == null ? sound : 'packages/$package/${audioCache.prefix}$sound';
    return AudioPool.create(
      source: AssetSource(path),
      audioCache: package == null ? audioCache : audioCacheFactory(prefix: ''),
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      audioContext: audioContext,
    );
  }

  static final AudioContext _defaultAudioContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();
}
