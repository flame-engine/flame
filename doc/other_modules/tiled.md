# Tiled

[Tiled](https://www.mapeditor.org/) is an great tool to design levels and maps.

Flame provides a package ([flame_tiled](https://github.com/flame-engine/flame_tiled)) which bundles
a [dart package](https://pub.dev/packages/tiled) that allows you to parse tmx (xml) files and access
the tiles, objects and everything in there.

Flame also provides a simple `Tiled` class and its component wrapper `TiledComponent`, for the map
rendering, which renders the tiles on the screen and supports rotations and flips.

## Layers

At its simplest, layers can be retrieved from a Tilemap by invoking:

```dart
getLayer<ObjectGroup>("myObjectGroupLayer");
getLayer<ImageLayer>("myImageLayer");
getLayer<TileLayer>("myTileLayer");
getLayer<Group>("myGroupLayer");
```

These methods will either return the requested layer type or null if it does not exist.

### Layer properties

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
features of the tmx and add custom behaviour (eg regions for triggers and walking areas, custom
animated objects).

## Full Example

You can check a working example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled/example).
