import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:synchronized/synchronized.dart';

/// Represents a function that can stop an audio playing.
typedef Stoppable = void Function();

/// An AudioPool is a provider of AudioPlayers that are pre-loaded with
/// local assets to minimize delays.
///
/// All AudioPlayers loaded are for the same [sound]. If you want multiple
/// sounds use multiple [AudioPool].
/// Use this class if you'd like have extremely quick firing, repetitive and
/// simultaneous sounds, like shooting a laser in a fast-paced spaceship game.
class AudioPool {
  final Map<String, AudioPlayer> _currentPlayers = {};
  final List<AudioPlayer> _availablePlayers = [];

  /// Instance of [AudioCache] to be used by all players.
  final AudioCache audioCache;

  /// The path of the sound of this pool.
  final String sound;

  /// Max and min numbers of players.
  final int minPlayers, maxPlayers;

  final Lock _lock = Lock();

  AudioPool._(
    this.sound, {
    required this.minPlayers,
    required this.maxPlayers,
    AudioCache? audioCache,
  }) : audioCache = audioCache ?? AudioCache.instance;

  /// Creates an [AudioPool] instance with the given parameters.
  static Future<AudioPool> create(
    String sound, {
    AudioCache? audioCache,
    int minPlayers = 1,
    required int maxPlayers,
  }) async {
    final instance = AudioPool._(
      sound,
      audioCache: audioCache,
      maxPlayers: maxPlayers,
      minPlayers: minPlayers,
    );
    for (var i = 0; i < instance.minPlayers; i++) {
      instance._availablePlayers.add(await instance._createNewAudioPlayer());
    }

    return instance;
  }

  /// Starts playing the audio, returns a function that can stop the audio.
  Future<Stoppable> start({double volume = 1.0}) async {
    return _lock.synchronized(() async {
      if (_availablePlayers.isEmpty) {
        _availablePlayers.add(await _createNewAudioPlayer());
      }
      final player = _availablePlayers.removeAt(0);
      _currentPlayers[player.playerId] = player;
      await player.setVolume(volume);
      await player.resume();

      late StreamSubscription<void> subscription;

      void stop() {
        _lock.synchronized(() async {
          final p = _currentPlayers.remove(player.playerId);
          if (p != null) {
            subscription.cancel();
            await p.stop();
            if (_availablePlayers.length >= maxPlayers) {
              await p.release();
            } else {
              _availablePlayers.add(p);
            }
          }
        });
      }

      subscription = player.onPlayerComplete.listen((_) => stop());

      return stop;
    });
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    final player = AudioPlayer()..audioCache = audioCache;
    await player.setSource(AssetSource(sound));
    await player.setReleaseMode(ReleaseMode.stop);
    return player;
  }
}
