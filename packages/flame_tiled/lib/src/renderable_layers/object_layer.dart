import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

/// An object layer has nothing of its own to draw, but it is part of the
/// component tree so that components can be added to it and be rendered at the
/// depth of the layer.
@internal
class ObjectLayer({
  required super.layer,
  required super.map,
  required super.destTileSize,
  super.filterQuality,
}) extends RenderableLayer<ObjectGroup> {
  @override
  void refreshCache() {}
}
