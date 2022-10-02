import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_tiled/src/mutable_transform.dart';

/// A select group of tiles from RenderableTiledMap that can be animated.
///
/// Tiles are nothing more than an x/y coordinate in each layer. TileStack lets
/// you collect a certain group of tiles out of all the layers, and then
/// set their positions.  This is typically done by using Flame's effects.
class TileStack extends Component implements PositionProvider {
  final List<MutableRSTransform> _tiles;

  /// The number of tiles in this stack.
  int get length => _tiles.length;

  TileStack(this._tiles);

  @override
  Vector2 get position => _tiles.first.position;

  @override
  set position(Vector2 position) {
    for (final tile in _tiles) {
      tile.position = position;
    }
  }
}
