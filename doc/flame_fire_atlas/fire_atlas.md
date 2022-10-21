# Flame fire atlas

Flame fire atlas is a texture atlas lib for Flame. By using `flame_fire_atlas` one can access images
and animations stored in a `.fa` texture atlas by referring to them by their named keys.


## FireAtlas

FireAtlas is a tool for handling texture atlases. Atlases can be created using the
[Fire Atlas Editor](https://fire-atlas.flame-engine.org).


### Creating Atlas

To create a texture atlas open [Fire Atlas Editor](https://fire-atlas.flame-engine.org).

Select new atlas and give the atlas a name, tile width, tile height and an image and press okay.
This will take you to the atlas editor.

To create a new `Sprite` in the atlas, select a portion and click the plus button on top left and
give the selection a name and then select type `Sprite` and press `Create Sprite`. You can now
see a preview in the right panel of editor.

To create a new `SpriteAnimation` in the atlas, select a portion and click the plus button on top
left and give the selection a name and then select type `Animation` and provide `frame count`
and `steps times (in milliseconds)` and select the checkbox to loop the animation, and then
press `Create Animation`. You can now see a preview of the animation in the right panel of the
editor.

Once you are done with editing you can download the fire atlas file from top left with
the `download` icon button.


## Texture atlas

A [Texture atlas](https://en.wikipedia.org/wiki/Texture_atlas) is an image that contains data from
several smaller images that have been packed together to reduce overall dimensions. With it, you
reduce the number of images loaded and can speed up the loading time of the game.


## Usage

To use the bridge library in your game you just need to add `flame_fire_atlas` to your pubspec.yaml,
as can be seen in
the [Flame Fire Atlas example](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example)
and in the pub.dev [installation instructions](https://pub.dev/packages/flame_fire_atlas).

Then you have the following methods at your disposal:

```dart
import 'package:flame_fire_atlas/flame_fire_atlas.dart';

// Load the atlas from your assets
// file at assets/atlas.fa
final atlas = await FireAtlas.loadAsset('atlas.fa');

//or when inside a game instance, the loadFireAtlas can be used:
// file at assets/atlas.fa
final atlas = await loadFireAtlas('atlas.fa');

// Get a Sprite with the given key.
FireAtlas.getSprite('sprite_name')

// Get a SpriteAnimation with the given key.
FireAtlas.getAnimation('animation_name')
```

To use FireAtlas in your game, load the fire atlas file in an `onLoad` method, either in your game
or a component. Then you can use `getSprite` and `getAnimation` to retrieve the mapped assets.

```dart
class ExampleGame extends FlameGame {

  late FireAtlas _atlas;

  @override
  Future<void> onLoad() async {
    _atlas = await loadFireAtlas('atlas.fa');

    add(
      SpriteComponent(
        size: Vector2(50, 50),
        position: Vector2(0, 50),
        sprite: _atlas.getSprite('sprite_name'),
      ),
    );

    add(
      SpriteAnimationComponent(
        size: Vector2(150, 100),
        position: Vector2(150, 100),
        animation: _atlas.getAnimation('animation_name'),
      ),
    );
  }

}
```


## Full Example

You can check an example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas/example).

