# Tiled

[Tiled](https://www.mapeditor.org/) is a great tool to design levels and maps.

Flame provides a package ([flame_tiled](https://github.com/flame-engine/flame_tiled)) that bundles a
[dart](https://pub.dev/packages/tiled) package which allows you to parse TMX (XML) files and access
the tiles, objects, and everything in there.

Flame also provides a simple `Tiled` class and its component wrapper `TiledComponent`, for the map
rendering, which renders the tiles on the screen and supports rotations and flips.


## Layer properties

The following properties are supported in the `Tiled` class:

| Property              | Supported?  |
| -----------           | ----------- |
| Visible               | ✅          |
| Opacity               | ✅          |
| Tint color            | ❌          |
| Horizontal offset     | ✅          |
| Horizontal offset     | ✅          |
| Parallax Factor       | ✅          |
| Custom properties     | ✅          |


## Tiles properties

- Tiles can have custom properties accessible at `tile.properties`.
- Tiles can have a custom `type` (or `class` starting in Tiled v1.9) accessible at `tile.type`.


## Other features

Other advanced features are not yet supported, but you can easily read the objects and other
features of the TMX and add custom behavior (eg regions for triggers and walking areas, custom
animated objects).
