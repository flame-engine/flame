# Structure

Flame has a proposed structure for your project that includes the standard Flutter `assets`
directory in addition to two children: `audio` and `images`.

If using the following example code:

```dart
void main() {
  FlameAudio.play('explosion.mp3');

  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
}
```

The following file structure is where Flame would expect to find the files:

```text
.
└── assets
    ├── audio
    │   └── explosion.mp3
    └── images
        ├── enemy.png
        └── player.png
```

Optionally you can split your `audio` folder into two subfolders, one for `music` and one for `sfx`.

Don't forget to add these files to your `pubspec.yaml` file:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
```

If you want to change this structure, this is possible by using the `prefix` parameter and creating
your instances of `AssetsCache`, `ImagesCache`, `AudioCache`, and `SoundPool`s, instead of using the
global ones provided by Flame.
