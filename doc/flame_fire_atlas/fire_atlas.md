# Flame fire atlas

Flame fire atlas is a texture atlas lib for Flame. Using `Flame fire atlas` one can access images
and animations stored in a `.fa` texture atlas by referring to them by their named keys.


## FireAtlas

FireAtlas is a tool for handling texture atlases. Atlases can be created using
the [Fire Atlas Editor](https://fire-atlas.flame-engine.org/#/).


## Texture atlas

A texture atlas is an image that contains data from several smaller images that have been packed
together to reduce overall dimensions.


## Usage

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

After installing the `flame_fire_atlas` package, you can add FiraAtlas (`.fa`) files in the assets
section of your `pubspec.yaml`.

For the examples below, your `pubspec.yaml` file needs to contain something like this:

```yaml
flutter:
  assets:
    - assets/caveace.fa
```

Then you have the following methods at your disposal:

```dart
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

// Load your exported fire atlas file.
loadFireAtlas
('caveace.fa')

// Get a Sprite with the given key.
FireAtlas.getSprite('bomb_ptero')

// Get a SpriteAnimation with the given key.
FireAtlas.getAnimation('bla')
```

To use FireAtlas in your game, load the fire atlas file in an `onLoad` method, either in your game
or a component. Then you can use `getSprite` and `getAnimation` to retrieve the mapped assets.

```dart
class ExampleGame extends FlameGame {

  late FireAtlas _atlas;

  @override
  Future<void> onLoad() async {
    _atlas = await loadFireAtlas('caveace.fa');

    add(
      SpriteComponent(
        size: Vector2(50, 50),
        position: Vector2(0, 50),
        sprite: _atlas.getSprite('shooting_ptero'),
      ),
    );

    add(
      SpriteComponent(
        size: Vector2(50, 50),
        position: Vector2(0, 50),
        sprite: _atlas.getSprite('bullet'),
      ),
    );
  }

}
```


## Full Example

You can check an example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example).

