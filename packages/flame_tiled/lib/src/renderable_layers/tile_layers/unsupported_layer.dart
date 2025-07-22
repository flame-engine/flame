import 'package:flame_tiled/flame_tiled.dart';
import 'package:meta/meta.dart';

// Represents a [RenderableLayer] that cannot be parsed by this package.
@internal
class UnsupportedLayer extends RenderableLayer {
  UnsupportedLayer({
    required super.layer,
    required super.map,
    required super.parent,
    required super.camera,
    required super.destTileSize,
  });

  @override
  void refreshCache() {}
}
