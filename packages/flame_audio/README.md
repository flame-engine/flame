<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds audio support for <a href="https://github.com/flame-engine/flame">Flame</a> using the <a href="https://github.com/luanpotter/audioplayers">audioplayers</a> package.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_audio" ><img src="https://img.shields.io/pub/v/flame_audio.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
# flame_audio

This package makes it easy to add audio capabilities to your games, integrating
[Audioplayers](https://github.com/bluefireteam/audioplayers) features seamless into your Flame game
code.

Add this as a dependency to your Flame game if you want to play background music,
ambient sounds, sound effects, etc. For the full documentation, visit [flame_audio](https://docs.flame-engine.org/latest/bridge_packages/flame_audio/flame_audio.html).


## How to use

Add your sound files to the assets section of your `pubspec.yaml`, and remember to run `pub get`
afterwards:

```yaml
flutter:
  assets:
    - assets/audio/
```

Every path is given in full, exactly as declared in the `pubspec.yaml`, nothing is prepended.


### General sounds

Use these built-in methods to play sounds in your Flame game:

```dart
import 'package:flame_audio/flame_audio.dart';

// For shorter reused audio clips, like sound effects
FlameAudio.play('assets/audio/explosion.mp3');

// For looping an audio file
FlameAudio.loop('assets/audio/music.mp3');

// For playing a longer audio file
FlameAudio.playLongAudio('assets/audio/music.mp3');

// For looping a longer audio file
FlameAudio.loopLongAudio('assets/audio/music.mp3');
```


### Background music

Start by initializing FlameAudio bgm.

```dart
FlameAudio.bgm.initialize();
```

Remember to call dispose to remove the observer.

```dart
FlameAudio.bgm.dispose();
```

To play a looping background music

```dart
import 'package:flame_audio/flame_audio.dart';

// play with optional volume param
FlameAudio.bgm.play('assets/audio/music/world-map.mp3', volume: .25);
```

To stop background music

```dart
FlameAudio.bgm.stop();
```

To pause and resume background music

```dart
FlameAudio.bgm.pause();
FlameAudio.bgm.resume();
```


### Caching

You can pre-load your sounds into the audioCache.
This prevents a delay for the first time an audio file is called.
The files are cached automatically after the first time.

```dart
// cache single track
await FlameAudio.audioCache.load('assets/audio/explosion.mp3');

// cache multiple tracks
await FlameAudio.audioCache.loadAll([
  'assets/audio/explosion.mp3',
  'assets/audio/music.mp3',
]);
```

To clear the cache

```dart
// clear specific track
FlameAudio.audioCache.clear('assets/audio/explosion.mp3');

// clear whole cache
FlameAudio.audioCache.clearCache();
```


### Audio pool

Use AudioPools if you have extremely quick firing, repetitive or simultaneous sounds.
To create an AudioPool:

```dart
AudioPool audioPool = await FlameAudio.createPool(
  'assets/audio/explosion.mp3',
  maxPlayers: 2,
);
audioPool.start();
```
