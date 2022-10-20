# Layers

At its simplest, layers can be retrieved from a Tilemap by invoking:

```dart
getLayer<ObjectGroup>("myObjectGroupLayer");
getLayer<ImageLayer>("myImageLayer");
getLayer<TileLayer>("myTileLayer");
getLayer<Group>("myGroupLayer");
```

These methods will either return the requested layer type or null if it does not exist.


## Full Example

You can check a working example
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled/example).
