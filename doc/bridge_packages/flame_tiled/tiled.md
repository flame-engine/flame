# Tiled

[Tiled] is a great tool to design levels and maps.  From [Tiled]'s documentation:

> Tiled is a 2D level editor that helps you develop the content of your game. Its
> primary feature is to edit tile maps of various forms, but it also supports
> free image placement as well as powerful ways to annotate your level with extra
> information used by the game. Tiled focuses on general flexibility while trying
> to stay intuitive.
>
> In terms of tile maps, it supports straight rectangular tile layers, but also
> projected isometric, staggered isometric and staggered hexagonal layers. A
> tileset can be either a single image containing many tiles, or it can be a
> collection of individual images. In order to support certain depth faking
> techniques, tiles and layers can be offset by a custom distance and their
> rendering order can be configured.


![Tiled Editor](../../images/TiledEditor.jpg)


Flame provides a package ([flame_tiled]) that bundles a [dart] package which allows you to parse TMX
(XML) files and access the tiles, objects, and everything in there.

The [dart] package provides a simple `Tiled` class and [flame_tiled] provides a component wrapper
`TiledComponent`, for the map rendering, which renders the tiles on the screen and supports
rotations and flips.

Infinite maps from the Tiled editor are supported. Tile positions, `getTileData`, and object
coordinates match the editor (including negative tile indices if you painted left or above the
origin). All chunks present in the file are cached at load time; very large infinite maps may
therefore be expensive. Chunk streaming based on the camera is not implemented yet.

Keep in mind that the size of a `TiledComponent` still comes from the map's `width` and `height`,
so tiles outside of that area (for example at negative indices) are rendered outside of the
component's bounds. `setTileData` only changes cells inside chunks that already exist in the map.


## Tiled Editor

You can choose to download the [Tiled] map editor and create interactive maps that can be loaded
into your game.  At its core, the [Tiled] map editor creates a TMX file that can be parsed and used
within your game.


[dart]: https://pub.dev/packages/tiled
[flame_tiled]: https://github.com/flame-engine/flame/tree/main/packages/flame_tiled
[Tiled]: https://www.mapeditor.org/
