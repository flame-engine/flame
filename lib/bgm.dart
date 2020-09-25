import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'flame.dart';

/// The looping background music class.
///
/// This class helps with looping background music management that reacts to
/// application lifecycle state changes. On construction, the instance is added
/// as an observer to the [WidgetsBinding] instance. A [dispose] function is
/// provided in case this functionality needs to be unloaded but the app needs
/// to keep running.
class Bgm extends WidgetsBindingObserver {
  bool _isRegistered = false;
  AudioPlayer audioPlayer;
  bool isPlaying = false;

  /// Registers a [WidgetsBinding] observer.
  ///
  /// This must be called for auto-pause and resume to work properly.
  void initialize() {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dispose the [WidgetsBinding] observer.
  void dispose() {
    if (!_isRegistered) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _isRegistered = false;
  }

  /// Plays and loops a background music file specified by [filename].
  ///
  /// The volume can be specified in the optional named parameter [volume]
  /// where `0` means off and `1` means max.
  ///
  /// It is safe to call this function even when a current BGM track is
  /// playing.
  Future<void> play(String filename, {double volume}) async {
    volume ??= 1;

    if (audioPlayer != null && audioPlayer.state != AudioPlayerState.STOPPED) {
      audioPlayer.stop();
    }

    isPlaying = true;
    audioPlayer = await Flame.audio.loopLongAudio(filename, volume: volume);
  }

  /// Stops the currently playing background music track (if any).
  Future<void> stop() async {
    isPlaying = false;
    if (audioPlayer != null) {
      await audioPlayer.stop();
    }
  }

  /// Resumes the currently played (but resumed) background music.
  Future<void> resume() async {
    if (audioPlayer != null) {
      isPlaying = true;
      await audioPlayer.resume();
    }
  }

  /// Pauses the background music without unloading or resetting the audio
  /// player.
  Future<void> pause() async {
    if (audioPlayer != null) {
      isPlaying = false;
      await audioPlayer.pause();
    }
  }

  /// Pre-fetch an audio and store it in the cache.
  ///
  /// Alias of `FlameAudio.load();`.
  Future<File> load(String file) => Flame.audio.load(file);

  /// Pre-fetch a list of audios and store them in the cache.
  ///
  /// Alias of `FlameAudio.loadAll();`.
  Future<List<File>> loadAll(List<String> files) => Flame.audio.loadAll(files);

  /// Clears the file in the cache.
  ///
  /// Alias of `FlameAudio.clear();`.
  void clear(String file) => Flame.audio.clear(file);

  /// Clears all the audios in the cache.
  ///
  /// Alias of `FlameAudio.clearAll();`.
  void clearAll() => Flame.audio.clearAll();

  /// Handler for AppLifecycleState changes.
  ///
  /// This function handles the automatic pause and resume when the app
  /// lifecycle state changes. There is NO NEED to call this function directly
  /// directly.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isPlaying && audioPlayer?.state == AudioPlayerState.PAUSED) {
        audioPlayer.resume();
      }
    } else {
      audioPlayer?.pause();
    }
  }
}
