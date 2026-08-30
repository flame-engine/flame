# Assets Directory Structure

Games rely heavily on external assets like images for sprites, audio files for sound effects, and
tile maps for levels. Organizing these files consistently ensures that Flame's built-in loaders
(and Flutter's own [asset system](https://docs.flutter.dev/ui/assets/assets-and-images)) can find
them without extra configuration.

Every Flame loader takes the **full path** of the asset, exactly as you declared it in your
`pubspec.yaml`. Nothing is prepended for you, so the string you write is the string that gets
loaded.

Flame has a proposed structure for your project that includes the standard Flutter `assets`
directory in addition to some children: `audio`, `images` and `tiles`. It is only a convention,
not a requirement.

If using the following example code:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await FlameAudio.play('assets/audio/explosion.mp3');

    // Load some images
    await Flame.images.load('assets/images/player.png');
    await Flame.images.load('assets/images/enemy.png');

    // Or load every image in a directory
    await Flame.images.loadAllImages(directory: 'assets/images/');

    final map1 = await TiledComponent.load('assets/tiles/level.tmx', tileSize);
  }
}
```

The following file structure matches those paths:

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

You are free to use any structure you like. Because every path is given in full, laying your
assets out differently needs no configuration at all, just different strings:

```dart
await Flame.images.load('gfx/sprites/player.png');
```

Note that the path is also the key the asset is cached under, so `Flame.images.fromCache` and
`Images.containsKey` take that same full path.

`AssetsCache` and `Images` can receive a custom
[`AssetBundle`](https://api.flutter.dev/flutter/services/AssetBundle-class.html).
This can be used to make Flame look for assets in a different location other than the `rootBundle`,
like the file system for example.
