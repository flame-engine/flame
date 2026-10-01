import 'dart:async' show scheduleMicrotask;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart' show Vector2;
import 'package:flame_flutter3d/src/host/has_flutter3d.dart';
import 'package:flame_flutter3d/src/transform/object3d_component.dart';
import 'package:flame_flutter3d/src/transform/plane.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:vector_math/vector_math.dart' show Matrix4, Vector3, Vector4;

/// A [CellGrid] as a bridged component: drawn as blocks, worn away by
/// [hitAt], grown by [setCell], and a world to move and collide in. A Space
/// Invaders shield, a Pac-Man maze, a Dig Dug field, a Surround arena.
///
/// The grid's corner is at this component's position, cell (0, 0) at the
/// top left as Flame sees it, one [CellGrid.cell] a cell; [size] is the
/// grid's. [cellAt] and [centreOf] turn a point of the game into a cell and
/// back, for a `GridMover` walking the maze or a game asking what is where.
///
/// **Two ways to draw it.** Merged, the default, the cells are one mesh,
/// drawn again from what is left after every change: cheap to draw, and a
/// whole grid rebuilt for each cell. [instanced], each cell is a slot in one
/// `InstancedMeshNode`, and a cell taken or put back is one slot: a field of
/// thousands dug a cell at a time rebuilt thousands of blocks for every
/// swing of the spade.
///
/// **Flame's collision sees every cell.** With [hitboxes], each cell there
/// has a passive `RectangleHitbox` of its own, taken away with it, so a ball
/// or a ghost meets the walls through Flame's own `CollisionCallbacks` and
/// Flame's own raycast, and [cellAt] of the contact point says which. One
/// `RectangleHitbox()` round the whole grid, as a shield uses, says only
/// that something reached it.
class CellGridComponent extends Object3dComponent {
  CellGridComponent({
    required this.grid,
    required this.device,
    required super.scene,
    required super.plane,
    required this.material,
    this.depth,
    this.colour,
    this.instanced = false,
    this.hitboxes = false,
    super.position,
    super.elevation,
  }) : super(
         node: SceneNode(name: 'cell grid'),
         direction: SyncDirection.flameToScene,
         size: Vector2(grid.columns * grid.cell, grid.rows * grid.cell),
       ) {
    if (instanced) {
      _placeAll();
    } else {
      _rebuild();
    }
  }

  final CellGrid grid;
  final GraphicsDevice device;
  final engine.Material material;

  /// How deep the blocks stand; a cell's size unless given.
  final double? depth;

  /// A colour the blocks are painted, if any.
  final Vector4? colour;

  /// Whether each cell is a slot in one instanced batch rather than a part
  /// of one merged mesh; see the class doc.
  final bool instanced;

  /// Whether each cell there has a Flame hitbox of its own.
  final bool hitboxes;

  MeshNode? _blocks;
  InstancedMeshNode? _batch;
  final Map<int, InstanceHandle> _slots = <int, InstanceHandle>{};
  final Map<int, RectangleHitbox> _cellHitboxes = <int, RectangleHitbox>{};

  BridgePlane get _flat =>
      BridgePlane(axis: plane.axis, constant: 0.0, flipY: plane.flipY);

  /// The cell [at], a point of the game, falls in, as (column, row); it may
  /// be outside the grid.
  (int, int) cellAt(Vector2 at) {
    final local = absoluteToLocal(at);
    return ((local.x / grid.cell).floor(), (local.y / grid.cell).floor());
  }

  /// The middle of cell ([column], [row]), in this component's parent's
  /// space: where a sibling standing in it is placed.
  Vector2 centreOf(int column, int row) => Vector2(
    position.x + (column + 0.5) * grid.cell,
    position.y + (row + 0.5) * grid.cell,
  );

  /// Takes away the cells within [radius] metres of [at], a point in the
  /// game's own coordinates, and draws what is left. True when a cell was
  /// there to take: the shot hit the shield rather than passing through a
  /// hole in it.
  bool hitAt(Vector2 at, {double radius = 0.6}) {
    final local = absoluteToLocal(at);
    var gone = false;
    for (var r = 0; r < grid.rows; r++) {
      for (var c = 0; c < grid.columns; c++) {
        final dx = (c + 0.5) * grid.cell - local.x;
        final dy = (r + 0.5) * grid.cell - local.y;
        if (dx * dx + dy * dy <= radius * radius && grid.isAlive(c, r)) {
          _change(c, r, alive: false);
          gone = true;
        }
      }
    }
    if (gone && !instanced) {
      _rebuild();
    }
    return gone;
  }

  /// Puts cell ([column], [row]) there, or takes it away, and draws the
  /// change. True when it changed.
  bool setCell(int column, int row, {bool alive = true}) {
    if (!_change(column, row, alive: alive)) {
      return false;
    }
    if (!instanced) {
      _rebuild();
    }
    return true;
  }

  bool _change(int column, int row, {required bool alive}) {
    if (!grid.set(column, row, alive: alive)) {
      return false;
    }
    final index = row * grid.columns + column;
    if (instanced) {
      if (alive) {
        _place(column, row);
      } else {
        final slot = _slots.remove(index);
        if (slot != null && slot.live) {
          _batch?.release(slot);
        }
      }
    }
    if (hitboxes && isMounted) {
      if (alive) {
        _addHitbox(column, row);
      } else {
        _cellHitboxes.remove(index)?.removeFromParent();
      }
    }
    return true;
  }

  @override
  void onMount() {
    super.onMount();
    if (!hitboxes) {
      return;
    }
    for (var r = 0; r < grid.rows; r++) {
      for (var c = 0; c < grid.columns; c++) {
        if (grid.isAlive(c, r)) {
          _addHitbox(c, r);
        }
      }
    }
  }

  void _addHitbox(int column, int row) {
    final index = row * grid.columns + column;
    if (_cellHitboxes.containsKey(index)) {
      return;
    }
    // Solid: a ball wholly inside a cell touches none of its edges, and
    // Flame reports a shape inside another only when the outer one is.
    final box = RectangleHitbox(
      position: Vector2(column * grid.cell, row * grid.cell),
      size: Vector2.all(grid.cell),
      collisionType: CollisionType.passive,
      isSolid: true,
    );
    _cellHitboxes[index] = box;
    add(box);
  }

  void _placeAll() {
    final block = CuboidShape(
      size: Vector3(grid.cell, depth ?? grid.cell, grid.cell),
    ).build();
    final batch = _batch = InstancedMeshNode(
      DeviceMesh.upload(
        device,
        colour == null ? block : block.withColor(colour!),
      ),
      material,
      capacity: grid.columns * grid.rows,
      name: 'cell grid blocks',
    );
    node.add(batch);
    for (var r = 0; r < grid.rows; r++) {
      for (var c = 0; c < grid.columns; c++) {
        if (grid.isAlive(c, r)) {
          _place(c, r);
        }
      }
    }
  }

  void _place(int column, int row) {
    final batch = _batch;
    if (batch == null) {
      return;
    }
    final slot = batch.acquire();
    slot.setTransform(
      Matrix4.translation(
        _flat.to3d(
          Vector2((column + 0.5) * grid.cell, (row + 0.5) * grid.cell),
        ),
      ),
    );
    _slots[row * grid.columns + column] = slot;
  }

  void _rebuild() {
    final flat = _flat;
    final data = grid.mesh(
      place: (x, y) => flat.to3d(Vector2(x, y)),
      depth: depth,
      colour: colour,
    );
    final old = _blocks;
    if (data == null) {
      old?.visible = false;
    } else {
      final blocks = MeshNode(DeviceMesh.upload(device, data), material);
      node.add(blocks);
      _blocks = blocks;
    }
    if (old != null && data != null) {
      old.removeFromParent();
      _letGo(old.mesh as DeviceMesh);
    }
  }

  /// **The last mesh goes with the grid.** Each hit gave the mesh before it
  /// back, and the one standing when the shield was removed stayed on the
  /// device: a level of four shields leaked four. Let go a moment later, as
  /// Object3dComponent lets go of what it owns, so a grid moved to another
  /// parent keeps it.
  @override
  void onRemove() {
    final mesh = _blocks?.mesh as DeviceMesh? ?? _batch?.mesh as DeviceMesh?;
    final game = findGame();
    final drawing = game is HasFlutter3d ? game.renderer : null;
    if (mesh != null) {
      scheduleMicrotask(() {
        if (isMounted || parent != null) {
          return;
        }
        _blocks?.removeFromParent();
        _blocks = null;
        _letGo(mesh, drawing);
      });
    }
    super.onRemove();
  }

  void _letGo(DeviceMesh mesh, [Renderer? through]) {
    final game = findGame();
    final drawing = through ?? (game is HasFlutter3d ? game.renderer : null);
    if (drawing != null) {
      drawing.releaseMeshAfterFrame(mesh);
    } else {
      device
        ..releaseGeometry(mesh.vertices)
        ..releaseGeometry(mesh.indices);
    }
  }
}
