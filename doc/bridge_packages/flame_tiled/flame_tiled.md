# flame_tiled

**flame_tiled** is the bridge package that connects the flame game engine to [Tiled] maps by parsing
TMX (XML) files and accessing the tiles, objects, and everything in there.

To use this, 
1. Create your own map by [Tiled]. 
2. Create a component and add it to the component tree as follows.

```dart
final component = await TiledComponent.load(
  'my_map.tmx',
  Vector2.all(32),
);

add(component);
```


## Limitations
### Flip
[Tiled] has a flip feature that flips tile to horizontally or vertically or even rotates it. It's also available in **flame_tiled** too.
But there is a caution to use this. It's fine with the normal map. But note that it would drop the performance if you have a big texture. The big texture means you have dozens of tilesets(or a huge tileset) and the sum of their dimension is thousands. Fortunately, you can set `ignoreFlip = true` and it disables all the flips in the map.

```dart
final component = await TiledComponent.load(
  'my_map.tmx',
  Vector2.all(32),
  ignoreFlip: true,
);
```

[Tiled]: https://www.mapeditor.org/

```{toctree}
:hidden:

Tiled  <tiled.md>
Layers <layers.md>
```
