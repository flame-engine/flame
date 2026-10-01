import 'package:flame/components.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flame_flutter3d/src/world/cell_grid_component.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:tiled/tiled.dart';

/// A level drawn in the Tiled editor, stood up in 3D: its tile layers as
/// blocks, its objects as whatever the game makes of them.
///
/// **What every game with a map read by hand.** A maze, a castle's rooms, a
/// mine's shafts are drawn far better in Tiled than typed as masks of `#`s,
/// and `flame_tiled` already reads them: `TiledComponent.load` gives its
/// `tileMap.map`, which this takes, or a test parses a `.tmx` with
/// `TiledMap.parseTmx`. Flame's own `TiledComponent` draws the tiles flat on
/// its canvas; here each tile layer becomes a [CellGridComponent], a block
/// where a tile is, on the game's plane.
///
/// **Set up in Tiled, not in code.** A tile layer's custom properties say
/// what it is: `solid` gives its cells Flame hitboxes, walls a ghost meets;
/// `depth` is how tall its blocks stand and `elevation` how far off the
/// plane; `merged` draws it as one mesh instead of instances, for a layer
/// that never changes. Its tint colour paints it. [material] gives each
/// layer its look.
///
/// **Objects are the game's.** Each object of an object layer is handed to
/// [spawn] with its middle in metres, and whatever component comes back is
/// added here, beside the grids, where a `GridMover` on it walks them.
///
/// One tile is [cell] metres, the tile's top left at `(0, 0)` of this
/// component.
class TiledWorld3d extends PositionComponent {
  TiledWorld3d({
    required this.map,
    required this.device,
    required this.scene,
    required this.plane,
    required this.material,
    this.cell = 1.0,
    this.spawn,
    super.position,
  }) : super(size: Vector2(map.width * cell, map.height * cell));

  /// The level, as `flame_tiled` or `TiledMap.parseTmx` read it.
  final TiledMap map;

  final GraphicsDevice device;
  final Scene scene;
  final BridgePlane plane;

  /// The look of a tile layer's blocks.
  final engine.Material Function(TileLayer layer) material;

  /// Metres a tile.
  final double cell;

  /// Makes the game's component for an object, placed at its middle in
  /// metres from this component's corner; null leaves it out.
  final Component? Function(TiledObject object, Vector2 at)? spawn;

  /// Each tile layer's grid, by the layer's name.
  final Map<String, CellGridComponent> grids = <String, CellGridComponent>{};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _read(map.layers);
  }

  Future<void> _read(List<Layer> layers) async {
    for (final layer in layers) {
      if (!layer.visible) {
        continue;
      }
      switch (layer) {
        case final Group group:
          await _read(group.layers);
        case final TileLayer tiles:
          final grid = _gridOf(tiles);
          grids[tiles.name] = grid;
          add(grid);
        case final ObjectGroup objects:
          for (final object in objects.objects) {
            final made = spawn?.call(object, _middleOf(object));
            if (made != null) {
              add(made);
            }
          }
        default:
          break;
      }
    }
  }

  CellGridComponent _gridOf(TileLayer layer) {
    final grid = CellGrid(columns: layer.width, rows: layer.height, cell: cell);
    final rows = layer.tileData ?? const <List<Gid>>[];
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        if (rows[r][c].tile != 0) {
          grid.set(c, r);
        }
      }
    }
    final properties = layer.properties;
    final tint = layer.tintColor;
    return CellGridComponent(
      grid: grid,
      device: device,
      scene: scene,
      plane: plane,
      material: material(layer),
      depth: _number(properties.getValue<Object>('depth')),
      elevation: _number(properties.getValue<Object>('elevation')) ?? 0.0,
      instanced: !(properties.getValue<bool>('merged') ?? false),
      hitboxes: properties.getValue<bool>('solid') ?? false,
      colour: tint == null
          ? null
          : Vector4(tint.red / 255.0, tint.green / 255.0, tint.blue / 255.0, 1),
    );
  }

  /// An object's middle in metres. A tile object is anchored at its bottom
  /// left in Tiled, a shape at its top left, and a point is where it is.
  Vector2 _middleOf(TiledObject object) {
    final x = object.x + object.width / 2.0;
    final y = object.gid != null
        ? object.y - object.height / 2.0
        : object.y + object.height / 2.0;
    return Vector2(x / map.tileWidth * cell, y / map.tileHeight * cell);
  }

  static double? _number(Object? value) => switch (value) {
    final num n => n.toDouble(),
    _ => null,
  };
}
