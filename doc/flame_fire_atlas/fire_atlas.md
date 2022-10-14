# FireAtlas

FireAtlas is a mapping file that can hold several Sprites and SpriteAnimations.

To
install [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas)
run this command:

```bash
flutter pub add flame_fire_atlas
```

this will add following line in your `pubspec.yaml` file:

```yaml
dependencies:
  flame_fire_atlas: VERSION
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame_fire_atlas/install).

After installing the `flame_fire_atlas` package, you can add mapping files in the assets section of
your
`pubspec.yaml`

For the examples below, your `pubspec.yaml` file needs to contain something like this:

```yaml
flutter:
  assets:
    - assets/caveace.fa
```

Then you have the following methods at your disposal:

```dart
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

// To load your Mapping file
loadFireAtlas('caveace.fa')

// To get Sprite with the given selectionId.
FireAtlas.getSprite('bomb_ptero')

// To get SpriteAnimation with the given selectionId.
FireAtlas.getAnimation('bla')
```

To use FireAtlas in game load mapping file in Game onLoad Method And Use [getSprite]
and [getAnimation] to retrieve mapped assets.

```dart
class ExampleGame extends FlameGame {

  late FireAtlas _atlas;

  @override
  Future<void> onLoad() async {
    _atlas = await loadFireAtlas('caveace.fa');

    add(
      SpriteAnimationComponent(
        size: Vector2(150, 100),
        animation: _atlas.getAnimation('shooting_ptero'),
      )
        ..y = 50,
    );

    add(
      SpriteComponent(
        size: Vector2(50, 50),
        sprite: _atlas.getSprite('bullet'),
      )
        ..y = 200,
    );
  }

}
```


## Full Example

You can check a working example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example).

