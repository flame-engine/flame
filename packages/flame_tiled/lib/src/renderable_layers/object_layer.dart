import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class ObjectLayer extends RenderableLayer<ObjectGroup> {
  ObjectLayer({
    required super.layer,
    required super.parent,
    required super.camera,
    required super.map,
    required super.destTileSize,
    super.filterQuality,
  });

  // ignore non-renderable layers when looping over the layers to render
  @override
  bool get visible => false;

  static Future<ObjectLayer> load(
    ObjectGroup layer,
    Component? parent,
    CameraComponent? camera,
    TiledMap map,
    Vector2 destTileSize,
    FilterQuality? filterQuality,
  ) async {
    return ObjectLayer(
      layer: layer,
      parent: parent,
      camera: camera,
      map: map,
      destTileSize: destTileSize,
      filterQuality: filterQuality,
    );
  }

  @override
  void refreshCache() {}
}
