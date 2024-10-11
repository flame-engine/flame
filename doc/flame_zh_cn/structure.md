# Structure

“Flame 为你的项目提供了一种建议的结构，除了标准的 Flutter assets 目录外，还包括一些子目录：audio、images 和 tiles。

如果使用以下示例代码：”

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

下面的文件结构是Flame预期要找到文件的地方。


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

你可以将 `audio` 文件夹分成两个子文件夹，一个用于 `music`，另一个用于 `sfx`。

别忘了将这些文件添加到你的 `pubspec.yaml` 文件中：

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
    - assets/tiles/level.tmx
```


如果你想改变这种结构，可以通过使用 `prefix` 参数并创建你自己的 `AssetsCache`、`Images` 和 `AudioCache` 实例来实现，而不是使用 Flame 提供的全局实例。

此外，`AssetsCache` 和 `Images` 可以接受一个自定义的[`AssetBundle`](https://api.flutter.dev/flutter/services/AssetBundle-class.html)。
这可以用来让 Flame 在不同的目录下查找资源，而不是默认的 `rootBundle`，例如可以在文件系统中查找。