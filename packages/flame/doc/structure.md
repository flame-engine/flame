# Structure

The only structure you are required to comply is having an assets folder with two sub folders: audio and images.

An example:

```dart
  Flame.audio.play('explosion.mp3');

  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
```

The file structure would have to be:

```
.
└── assets
    ├── audio
    │   └── explosion.mp3
    └── images
        ├── enemy.png
        └── player.png
```

Optionally you can split your `audio` folder into two subfolders, one for `music` and one for `sfx`.
Be mindful of configuring the `prefix` property correctly if you are changing this structure.

Don't forget to add these files to your `pubspec.yaml` file:

```
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
```
