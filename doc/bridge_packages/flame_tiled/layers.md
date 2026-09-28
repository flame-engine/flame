# Layers

At its simplest, layers can be retrieved from a Tilemap by invoking:

```dart
getLayer<ObjectGroup>("myObjectGroupLayer");
getLayer<ImageLayer>("myImageLayer");
getLayer<TileLayer>("myTileLayer");
getLayer<Group>("myGroupLayer");
```

These methods will either return the requested layer type or null if it does not exist.


## Layers as components

Every layer of a `TiledComponent` is a `RenderableLayer`, which is a `PositionComponent` that is a
child of the map (or of its group layer) in the same order as in Tiled. This means that any
component that you add to a layer is rendered right after that layer, and underneath the layers
that follow it in the map. This is how you make a foreground layer obscure your sprites:

```dart
final map = await TiledComponent.load('assets/tiles/map.tmx', Vector2.all(16));
world.add(map);

final ground = map.tileMap.getRenderableLayer('Ground');
ground?.add(player);
```

`getRenderableLayer` also finds layers that are nested inside of group layers.

The `position` of a layer is the sum of its offset in Tiled and the displacement for its parallax
factor, and it is recalculated every time the map is rendered. To move a layer, change its
`offsetX` and `offsetY` instead of its `position`. Components added to a layer move with it, which
also applies to the parallax scrolling of the layer.

Parallax scrolling is calculated against the camera that the map is rendered through, with the
center of the view as the reference point, just like in Tiled. If you render the map outside of a
`CameraComponent`, set `RenderableTiledMap.camera` to the camera to calculate the parallax
against.


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
