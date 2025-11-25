# AudioPool

An AudioPool is a provider of AudioPlayers that are pre-loaded with local assets to minimize audio
playback delays. This is particularly useful in fast-paced games where sound effects need to trigger
quickly and potentially overlap with each other.

A single AudioPool always plays the same sound, usually a quick sound effect that might need to be
played repeatedly or simultaneously, such as:

- Shooting sounds in a space shooter
- Jump sounds in a platformer
- Explosion effects
- Collecting coins or items
- Enemy hit sounds


## How It Works

AudioPool works by creating and pre-loading a pool of AudioPlayer instances that are all configured
to play the same sound. When you need to play the sound:

1. The pool gives you an available player from its collection
2. If no player is available, a new player is created on demand
3. When a sound finishes playing or is stopped manually, the player is returned to the pool for reuse,
   unless the pool already has reached its maximum size limit, in which case the player is released

This approach significantly reduces latency compared to creating new AudioPlayer instances on demand,
while also managing memory by limiting the maximum size of the pool.


## Creating an AudioPool

There are multiple ways to create an AudioPool:


### Using FlameAudio Helper

The simplest approach is to use the helper method in `FlameAudio`, which conveniently uses Flame's
global audio cache:

```dart
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  // Create a pool with minimum 1 player and maximum 2 players
  // This automatically uses Flame's global audio cache
  AudioPool explosionSoundPool = await FlameAudio.createPool(
    'explosion.mp3',
    minPlayers: 1,
    maxPlayers: 2,
  );
}
```


### Creating Directly with Source

You can also create an AudioPool by directly using the static factory methods:

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  // Create a pool with a specific Source
  AudioPool explosionSoundPool = await AudioPool.create(
    source: AssetSource('explosion.mp3'),
    minPlayers: 1,
    maxPlayers: 2,
    audioCache: FlameAudio.audioCache, // Optional
  );
}
```


### Creating from Asset Path

For convenience, you can create an AudioPool from just the asset path:

```dart
import 'package:flame_audio/flame_audio.dart';

Future<void> loadSounds() async {
  AudioPool explosionSoundPool = await AudioPool.createFromAsset(
    path: 'explosion.mp3',
    minPlayers: 1,
    maxPlayers: 2,
    audioCache: FlameAudio.audioCache, // Optional
  );
}
```

The parameters are:

- `source` or `path`: The audio source to play (either as a Source object or asset path)
- `minPlayers`: The initial number of AudioPlayers to create and preload (default: 1)
- `maxPlayers`: The maximum number of AudioPlayers that can be kept in the pool
- `audioCache`: Optional AudioCache instance to use
- `audioContext`: Optional audio context to be used by all players in the pool


## Using an AudioPool

Once you've created an AudioPool, you can start playing sounds:

```dart
// Play the sound with default volume (1.0)
final stopFunction = await audioPool.start();

// Play the sound with custom volume
final stopFunction = await audioPool.start(volume: 0.5);

// Later, you can stop the sound if needed
await stopFunction();
```

The `start()` method returns a `StopFunction` that you can call to stop the sound before it completes
naturally.


## Managing the Pool

AudioPool provides a `dispose()` method to release resources when you no longer need the pool:

```dart
// When you're done with the pool
await audioPool.dispose();
```


## Example Usage

Here's a complete example showing how to use AudioPools in a Flame game:

```dart
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

class MyGame extends FlameGame {
  late AudioPool laserSound;
  late AudioPool explosionSound;

  @override
  Future<void> onLoad() async {
    // Load sound effects into audio pools
    laserSound = await FlameAudio.createPool(
      'laser.mp3',
      minPlayers: 3,
      maxPlayers: 6,
    );

    explosionSound = await FlameAudio.createPool(
      'explosion.mp3',
      minPlayers: 2,
      maxPlayers: 4,
    );
  }

  void fireLaser() async {
    // Play the laser sound effect - can be called rapidly
    final stop = await laserSound.start();

    // If you need to stop the sound early:
    // await stop();
  }

  void enemyDestroyed() async {
    // Play explosion sound effect
    await explosionSound.start(volume: 0.7);
  }

  @override
  Future<void> onRemove() async {
    await super.onRemove();

    // Clean up resources when the game component is removed
    await laserSound.dispose();
    await explosionSound.dispose();
  }
}
```

You can also find the interactive example in [Flame Basic](https://examples.flame-engine.org/)
