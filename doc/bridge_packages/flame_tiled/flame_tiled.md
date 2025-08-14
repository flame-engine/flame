# flame_tiled

**flame_tiled** is the bridge package that connects the flame game engine to [Tiled] maps by parsing
TMX (XML) files and accessing the tiles, objects, and everything in there.

To use this,

1. Create your own map by using [Tiled].
2. Create a `TiledComponent` and add it to the component tree as follows:

```dart
final component = await TiledComponent.load(
  'my_map.tmx',
  Vector2.all(32),
);

add(component);
```


## TiledComponent

Tiled is a free and open source, full-featured level and map editor for your platformer or
RPG game. Currently we have an "in progress" implementation of a Tiled component. This API
uses the lib [tiled.dart](https://github.com/flame-engine/tiled.dart) to parse map files and
render visible layers using the performant `SpriteBatch` for each layer.

Supported map types include: Orthogonal, Isometric, Hexagonal, and Staggered.

Orthogonal | Hexagonal             |  Isomorphic
:--:|:-------------------------:|:-------------------------:
![An example of an orthogonal map](../../images/orthogonal.png)|![An example of hexagonal map](../../images/pointy_hex_even.png) |  ![An example of isomorphic map](../../images/tile_stack_single_move.png)

An example of how to use the API can be found
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled/example).


### TileStack

Once a `TiledComponent` is loaded, you can select any column of (x,y) tiles in a `tileStack` to
then add animation. Removing the stack will not remove the tiles from the map.

> **Note**: This currently only supports position based effects.

```dart
void onLoad() {
  final stack = map.tileMap.tileStack(4, 0, named: {'floor_under'});
  stack.add(
    SequenceEffect(
      [
        MoveEffect.by(
          Vector2(5, 0),
          NoiseEffectController(duration: 1, frequency: 20),
        ),
        MoveEffect.by(Vector2.zero(), LinearEffectController(2)),
      ],
      repeatCount: 3,
    )
      ..onComplete = () => stack.removeFromParent(),
  );
  map.add(stack);
}
```


### TileAtlas

When a tilemap has multiple images (from multiple tilesets) `TiledComponent` uses a `TileAtlas` to
pack all those image into a single big image (a.k.a atlas). This helps in rendering the whole map in
a single draw call. But is there a limit on how big this atlas can be based on the target platform
and hardware. As it is not possible to query this max size from Flame or Flutter as of now,
`TiledComponent` limits the atlas to `4096x4096` for web and `8192x8192` for all other platforms.

These limits should work well for most cases. But in case you are sure that your target platform can
support bigger atlas and want to override the limits used by `TiledComponent` you can do so by
passing in the `atlasMaxX` and `atlasMaxX` values to `TiledComponent.load`.

NOTE: This is not recommended as such huge sizes might not work with all hardware. Instead consider
resizing the original tileset images so that when packed they fit with the limits.

```dart
final component = await TiledComponent.load(
  'my_map.tmx',
  Vector2.all(32),
  atlasMaxX: 9216,
  atlasMaxY: 9216,
);

add(component);
```


## Limitations


### Flip

[Tiled] has a feature that allows you to flip a tile horizontally or vertically, or even rotate it.

`flame_tiled` supports this but if you are using a large texture and have flipped tiles there will
be a drop in performance. If you want to ignore any flips in your tilemap you can set the
`ignoreFlip` to false in the constructor.

**Note**: A large texture in this context means one with multiple tilesets (or a huge tileset)
where the sum of their dimensions are in the thousands.

```dart
final component = await TiledComponent.load(
  'my_map.tmx',
  Vector2.all(32),
  ignoreFlip: true,
);
```


### Clearing images cache

If you have called `Flame.images.clearCache()` you also need to call `TiledAtlas.clearCache()` to
remove disposed images from the tiled cache. It might be useful if your next game map have completely
different tiles than the previous.

[Tiled]: https://www.mapeditor.org/


## Troubleshooting


### My game shows "lines" and artifacts between the map tiles

This is caused by the imprecision found in float-pointing numbers in computer science.

Check this [Article](https://verygood.ventures/blog/solving-super-dashs-rendering-challenges-eliminating-ghost-lines-for-a-seamless-gaming-experience)
to learn more about the issue and how it can be solved.

```{toctree}
:hidden:

Tiled  <tiled.md>
Layers <layers.md>
```
