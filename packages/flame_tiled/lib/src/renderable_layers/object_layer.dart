import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class ObjectLayer extends RenderableLayer<ObjectGroup> {
  ObjectLayer({
    required super.layer,
    required super.parent,
    required super.map,
    required super.destTileSize,
  });

  @override
  void render(Canvas canvas, Camera? camera) {
    // nothing to do
  }

  // ignore non-renderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<ObjectLayer> load(
    ObjectGroup layer,
    TiledMap map,
    Vector2 destTileSize,
  ) async {
    return ObjectLayer(
      layer: layer,
      parent: null,
      map: map,
      destTileSize: destTileSize,
    );
  }

  @override
  void handleResize(Vector2 canvasSize) {}

  @override
  void refreshCache() {}

  @override
  void update(double dt) {}
}
