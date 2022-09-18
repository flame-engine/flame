part of '../renderable_tile_map.dart';

class _ObjectLayer extends _RenderableLayer<ObjectGroup> {
  _ObjectLayer(
    super.layer,
    super.parent,
    super.map,
    super.destTileSize,
  );

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore unrenderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<_ObjectLayer> load(
    ObjectGroup layer,
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    return _ObjectLayer(layer, null, map, destTileSize);
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @override
  void refreshCache() {}
}
