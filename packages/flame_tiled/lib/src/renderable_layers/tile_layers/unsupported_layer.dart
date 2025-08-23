import 'package:flame_tiled/flame_tiled.dart';
import 'package:meta/meta.dart';

/// An instance of this class represents a [RenderableLayer] that could not be
/// parsed by this package.
///
/// Because every [RenderableLayer]'s offsets are accumulated and used by their
/// down-stream child components during rendering, an [UnsupportedLayer]
/// must be retained in the component tree. In this way, offsets can propagate
/// correctly even if this package lacks features in newer Tiled versions.
@internal
class UnsupportedLayer extends RenderableLayer {
  UnsupportedLayer({
    required super.layer,
    required super.map,
    required super.parent,
    required super.camera,
    required super.destTileSize,
    required super.layerPaintFactory,
  });

  @override
  void refreshCache() {}
}
