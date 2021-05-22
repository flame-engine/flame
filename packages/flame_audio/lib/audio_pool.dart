import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:synchronized/synchronized.dart';

typedef Stoppable = void Function();

/// An AudioPool is a provider of AudioPlayers that leaves them pre-loaded to minimize delays.
///
/// All AudioPlayers loaded are for the same [sound]. If you want multiple sounds use multiple [AudioPool].
/// Use this class if you'd like have extremely quick firing, repetitive and simultaneous sounds, like shooting a laser in a fast-paced spaceship game.
class AudioPool {
  final AudioCache _cache;
  final Map<String, AudioPlayer> _currentPlayers = {};
  final List<AudioPlayer> _availablePlayers = [];

  final String sound;
  final bool repeating;
  final int minPlayers, maxPlayers;

  final Lock _lock = Lock();

  AudioPool._(
    this.sound, {
    bool? repeating,
    int? maxPlayers,
    int? minPlayers = 1,
    String? prefix,
  })  : _cache = AudioCache(prefix: prefix ?? 'assets/audio/sfx/'),
        repeating = repeating ?? false,
        maxPlayers = maxPlayers ?? 1,
        minPlayers = minPlayers ?? 1;

  static Future<AudioPool> create(
    String sound, {
    bool? repeating,
    int? maxPlayers,
    int? minPlayers = 1,
    String? prefix,
  }) async {
    final instance = AudioPool._(
      sound,
      repeating: repeating,
      maxPlayers: maxPlayers,
      minPlayers: minPlayers,
      prefix: prefix,
    );
    for (var i = 0; i < instance.minPlayers; i++) {
      instance._availablePlayers.add(await instance._createNewAudioPlayer());
    }

    return instance;
  }

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

      subscription = player.onPlayerCompletion.listen((_) {
        if (repeating) {
          player.resume();
        } else {
          stop();
        }
      });

      return stop;
    });
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    final player = AudioPlayer();
    final url = (await _cache.load(sound)).path;
    await player.setUrl(url);
    await player.setReleaseMode(ReleaseMode.STOP);
    return player;
  }
}
