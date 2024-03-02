<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds support for parsing and rendering tilemap exported from <a href="https://www.spritefusion.com/">Sprite Fusion</a> directly in <a href="https://flame-engine.org/">Flame engine</a>.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_sprite_fusion" ><img src="https://img.shields.io/pub/v/flame_sprite_fusion.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->


## Features

Provides a component called `SpriteFusionTilemapComponent` to easily load json exports from Sprite Fusion.
This component works exactly like any other Flame component and plays nicely with rest of the Flame
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
final map = await SpriteFusionTilemapComponent.load(
  mapJsonFile: 'map.json',
  spriteSheetFile: 'spritesheet.png'
);

//Add it to the game world.
world.add(map);
```


## Additional information


> :warning: Under the current sprite batch implementation, you might experience extra lines while
rendering due to a bug in Flutter, see [this issue](https://github.com/flame-engine/flame/issues/1152).
