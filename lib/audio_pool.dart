import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:synchronized/synchronized.dart';

typedef void Stoppable();

/// An AudioPool is a provider of AudioPlayers that leaves them pre-loaded to minimize delays.
///
/// All AudioPlayers loaded are for the same [sound]. If you want multiple sounds use multiple [AudioPool].
/// Use this class if you'd like have extremely quick firing, repetitive and simultaneous sounds, like shooting a laser in a fast-paced spaceship game.
class AudioPool {
  AudioCache cache;
  Map<String, AudioPlayer> currentPlayers = {};
  List<AudioPlayer> availablePlayers = [];

  String sound;
  bool repeating;
  int minPlayers, maxPlayers;

  final Lock _lock = Lock();

  AudioPool(this.sound,
      {this.repeating = false,
      this.maxPlayers = 1,
      this.minPlayers = 1,
      String prefix = 'assets/audio/sfx/'}) {
    cache = AudioCache(prefix: prefix);
  }

  Future init() async {
    for (int i = 0; i < minPlayers; i++) {
      availablePlayers.add(await _createNewAudioPlayer());
    }
  }

  Future<Stoppable> start({double volume = 1.0}) async {
    return _lock.synchronized(() async {
      if (availablePlayers.isEmpty) {
        availablePlayers.add(await _createNewAudioPlayer());
      }
      final AudioPlayer player = availablePlayers.removeAt(0);
      currentPlayers[player.playerId] = player;
      await player.setVolume(volume);
      await player.resume();

      StreamSubscription<void> subscription;

      final Stoppable stop = () {
        _lock.synchronized(() async {
          final AudioPlayer p = currentPlayers.remove(player.playerId);
          subscription?.cancel();
          await p.stop();
          if (availablePlayers.length >= maxPlayers) {
            await p.release();
          } else {
            availablePlayers.add(p);
          }
        });
      };

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
    final AudioPlayer player = AudioPlayer();
    final String url = (await cache.load(sound)).path;
    await player.setUrl(url);
    await player.setReleaseMode(ReleaseMode.STOP);
    return player;
  }
}
