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

```{toctree}
:hidden:

Tiled  <tiled.md>
Layers <layers.md>
```
