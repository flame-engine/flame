# Layers

At its simplest, layers can be retrieved from a Tilemap by invoking:

```dart
getLayer<ObjectGroup>("myObjectGroupLayer");
getLayer<ImageLayer>("myImageLayer");
getLayer<TileLayer>("myTileLayer");
getLayer<Group>("myGroupLayer");
```

These methods will either return the requested layer type or null if it does not exist.


## Layer properties

The following Tiled properties are supported:

- [x] Visible
- [x] Opacity
- [ ] Tint color
- [x] Horizontal offset
- [x] Vertical offset
- [x] Parallax factor
- [x] Custom properties


## Tiles properties

- Tiles can have custom properties accessible at `tile.properties`.
- Tiles can have a custom `type` (or `class` starting in Tiled v1.9) accessible at `tile.type`.


## Other features

Other advanced features are not yet supported, but you can easily read the objects and other
features of the TMX and add custom behavior (eg regions for triggers and walking areas, custom
animated objects).


## Full Example

You can check a working example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled/example).
