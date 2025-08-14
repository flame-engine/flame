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
    required super.layerPaintFactory,
    super.filterQuality,
  });

  static Future<ObjectLayer> load(
    ObjectGroup layer,
    Component? parent,
    CameraComponent? camera,
    TiledMap map,
    Vector2 destTileSize,
    Paint Function(double opacity) layerPaintFactory,
    FilterQuality? filterQuality,
  ) async {
    return ObjectLayer(
      layer: layer,
      parent: parent,
      camera: camera,
      map: map,
      destTileSize: destTileSize,
      layerPaintFactory: layerPaintFactory,
      filterQuality: filterQuality,
    );
  }

  @override
  void refreshCache() {}
}
