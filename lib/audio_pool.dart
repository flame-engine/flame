import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:synchronized/synchronized.dart';

typedef void Stoppable();

class AudioPool {

  AudioCache cache;
  Map<String, AudioPlayer> currentPlayers = {};
  List<AudioPlayer> availablePlayers = [];

  String sound;
  bool repeating;
  int minPlayers, maxPlayers;

  Lock _lock = new Lock();

  AudioPool(this.sound, { this.repeating = false, this.maxPlayers = 1, this.minPlayers = 1, String prefix = 'audio/sfx/' }) {
    cache = new AudioCache(prefix: prefix);
  }

  void init() async {
    for (int i = 0; i < minPlayers; i++) {
      availablePlayers.add(await _createNewAudioPlayer());
    }
  }

  Future<Stoppable> start({ double volume = 1.0 }) async {
    return _lock.synchronized(() async {
      if (availablePlayers.isEmpty) {
        availablePlayers.add(await _createNewAudioPlayer());
      }
      AudioPlayer player = availablePlayers.removeAt(0);
      currentPlayers[player.playerId] = player;
      await player.setVolume(volume);
      await player.resume();
      Stoppable stop = () {
        _lock.synchronized(() async {
          AudioPlayer p = currentPlayers.remove(player.playerId);
          p.completionHandler = null;
          await p.stop();
          if (availablePlayers.length >= maxPlayers) {
            await p.release();
          } else {
            availablePlayers.add(p);
          }
        });
      };
      if (repeating) {
        player.completionHandler = player.resume;
      } else {
        player.completionHandler = stop;
      }
      return stop;
    });
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    AudioPlayer player = new AudioPlayer();
    String url = (await cache.load(sound)).path;
    await player.setUrl(url);
    await player.setReleaseMode(ReleaseMode.STOP);
    return player;
  }
}
