import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

//ignore_for_file: invalid_null_aware_operator

/// {@template _bgm}
/// The looping background music class.
///
/// This class helps with looping background music management that reacts to
/// application lifecycle state changes. On construction, the instance is added
/// as an observer to the [WidgetsBinding] instance. A [dispose] function is
/// provided in case this functionality needs to be unloaded but the app needs
/// to keep running.
/// {@endtemplate}
class Bgm extends WidgetsBindingObserver {
  bool _isRegistered = false;

  /// [AudioCache] instance of the [Bgm].
  late AudioCache audioCache;

  /// The [AudioPlayer] instance that is currently playing the audio.
  AudioPlayer? audioPlayer;

  /// Whether [Bgm] is playing or not.
  bool isPlaying = false;

  /// {@macro _bgm}
  Bgm({AudioCache? audioCache}) : audioCache = audioCache ?? AudioCache();

  /// Registers a [WidgetsBinding] observer.
  ///
  /// This must be called for auto-pause and resume to work properly.
  void initialize() {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
  }

  /// Dispose the [WidgetsBinding] observer.
  void dispose() {
    if (!_isRegistered) {
      return;
    }
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _isRegistered = false;
  }

  /// Plays and loops a background music file specified by [filename].
  ///
  /// The volume can be specified in the optional named parameter [volume]
  /// where `0` means off and `1` means max.
  ///
  /// It is safe to call this function even when a current BGM track is
  /// playing.
  Future<void> play(String filename, {double volume = 1}) async {
    final currentPlayer = audioPlayer;
    if (currentPlayer != null && currentPlayer.state != PlayerState.STOPPED) {
      currentPlayer.stop();
    }

    isPlaying = true;
    audioPlayer = await audioCache.loop(filename, volume: volume);
  }

  /// Stops the currently playing background music track (if any).
  Future<void> stop() async {
    isPlaying = false;
    if (audioPlayer != null) {
      await audioPlayer!.stop();
    }
  }

  /// Resumes the currently played (but resumed) background music.
  Future<void> resume() async {
    if (audioPlayer != null) {
      isPlaying = true;
      await audioPlayer!.resume();
    }
  }

  /// Pauses the background music without unloading or resetting the audio
  /// player.
  Future<void> pause() async {
    if (audioPlayer != null) {
      isPlaying = false;
      await audioPlayer!.pause();
    }
  }

  /// Pre-fetch an audio and store it in the cache.
  ///
  /// Alias of `audioCache.load();`.
  Future<Uri> load(String file) => audioCache.load(file);

  /// Pre-fetch an audio and store it in the cache.
  ///
  /// Alias of `audioCache.loadAsFile();`.
  Future<File> loadAsFile(String file) => audioCache.loadAsFile(file);

  /// Pre-fetch a list of audios and store them in the cache.
  ///
  /// Alias of `audioCache.loadAll();`.
  Future<List<Uri>> loadAll(List<String> files) => audioCache.loadAll(files);

  /// Clears the file in the cache.
  ///
  /// Alias of `audioCache.clear();`.
  void clear(Uri file) => audioCache.clear(file);

  /// Clears all the audios in the cache.
  ///
  /// Alias of `audioCache.clearAll();`.
  void clearAll() => audioCache.clearAll();

  /// Handler for AppLifecycleState changes.
  ///
  /// This function handles the automatic pause and resume when the app
  /// lifecycle state changes. There is NO NEED to call this function directly
  /// directly.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isPlaying && audioPlayer?.state == PlayerState.PAUSED) {
        audioPlayer?.resume();
      }
    } else {
      audioPlayer?.pause();
    }
  }
}

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
///
/// See more: https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
T? _ambiguate<T>(T? value) => value;
