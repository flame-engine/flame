import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

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

  /// The [AudioPlayer] instance that is used to play the audio.
  AudioPlayer audioPlayer;

  /// Whether [Bgm] is playing or not.
  bool isPlaying = false;

  /// {@macro _bgm}
  Bgm({AudioCache? audioCache})
    : audioPlayer = AudioPlayer()
        ..audioCache = audioCache ?? AudioCache.instance;

  /// Registers a [WidgetsBinding] observer.
  ///
  /// This must be called for auto-pause and resume to work properly.
  Future<void> initialize({AudioContext? audioContext}) async {
    if (_isRegistered) {
      return;
    }
    _isRegistered = true;

    // Avoid requesting audio focus
    audioContext ??= AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    await audioPlayer.setAudioContext(audioContext);

    WidgetsBinding.instance.addObserver(this);
  }

  /// Dispose the [WidgetsBinding] observer.
  Future<void> dispose() async {
    await audioPlayer.dispose();
    if (!_isRegistered) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    _isRegistered = false;
  }

  /// Plays and loops a background music file specified by [fileName].
  ///
  /// The volume can be specified in the optional named parameter [volume]
  /// where `0` means off and `1` means max.
  ///
  /// It is safe to call this function even when a current BGM track is
  /// playing.
  Future<void> play(String fileName, {double volume = 1}) async {
    await audioPlayer.release();
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.setVolume(volume);
    await audioPlayer.setSource(AssetSource(fileName));
    await audioPlayer.resume();
    isPlaying = true;
  }

  /// Stops the currently playing background music track (if any).
  Future<void> stop() async {
    isPlaying = false;
    await audioPlayer.stop();
  }

  /// Resumes the currently played (but resumed) background music.
  Future<void> resume() async {
    isPlaying = true;
    await audioPlayer.resume();
  }

  /// Pauses the background music without unloading or resetting the audio
  /// player.
  Future<void> pause() async {
    isPlaying = false;
    await audioPlayer.pause();
  }

  /// Handler for AppLifecycleState changes.
  ///
  /// This function handles the automatic pause and resume when the app
  /// lifecycle state changes. There is NO NEED to call this function directly
  /// directly.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (isPlaying && audioPlayer.state == PlayerState.paused) {
        audioPlayer.resume();
      }
    } else {
      audioPlayer.pause();
    }
  }
}
