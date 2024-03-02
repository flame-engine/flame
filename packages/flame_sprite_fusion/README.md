This package adds support for parsing and rendering tilemap exported from [Sprite Fusion](https://www.spritefusion.com/)
directly in [Flame engine](https://flame-engine.org/).


## Features

Provides a component called `SpriteFusionTilemapComponent` to easily load json exports from Sprite Fusion.
This component works exactly like any other Flame component and plays nices with rest of the Flame
Component System (a.k.a FCS).


## Getting started

- To get started, first add `flame_sprite_fusion` as a dependency in your flutter project.

  ```bash
  flutter pub add flame_sprite_fusion
  ```

- Then place the `map.json` and `spritesheet.png` exported from Sprite Fusion into the `assets/tiles/`
and `assets/images/` directory of your project respectively.

- Finally load the map and spritesheet using `SpriteFusionTilemapComponent` in your game.


## Usage


```dart
// Load the map.
final map = await SpriteFusionTilemapComponent.load('map.json', 'spritesheet.png');

//Add it to the game world.
world.add(map);
```


## Additional information


> :warning: Under the current sprite batch implementation, you might experience extra lines while
rendering due to a bug in Flutter, see [this issue](https://github.com/flame-engine/flame/issues/1152).
