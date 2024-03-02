# Structure

Flame has a proposed structure for your project that includes the standard Flutter `assets`
directory in addition to some children: `audio`, `images` and `tiles`.

If using the following example code:

```dart
void main() {
  FlameAudio.play('explosion.mp3');

  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
  
  final map1 = TiledComponent.load('level.tmx', tileSize);
  
  final map2 = await SpriteFusionTilemapComponent.load(
    mapJsonFile: 'map.json',
    spriteSheetFile: 'spritesheet.png'
  );
}
```

The following file structure is where Flame would expect to find the files:

```text
.
└── assets
    ├── audio
    │   └── explosion.mp3
    ├── images
    │   ├── enemy.png
    │   ├── player.png
    │   └── spritesheet.png
    └── tiles
        ├── level.tmx
        └── map.json
```

Optionally you can split your `audio` folder into two subfolders, one for `music` and one for `sfx`.

Don't forget to add these files to your `pubspec.yaml` file:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
    - assets/tiles/level.tmx
```

If you want to change this structure, this is possible by using the `prefix` parameter and creating
your instances of `AssetsCache`, `Images`, and `AudioCache`, instead of using the
global ones provided by Flame.

Additionally, `AssetsCache` and `Images` can receive a custom
[`AssetBundle`](https://api.flutter.dev/flutter/services/AssetBundle-class.html).
This can be used to make Flame look for assets in a different location other the `rootBundle`,
like the file system for example.
