/// A grid as a world: walked a cell at a time, drawn as instances, and met
/// through Flame's own collision.
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d, HasCollisionDetection {}

Future<({_World game, CellGridComponent maze})> _maze(
  List<String> mask, {
  bool instanced = false,
  bool hitboxes = false,
}) async {
  final device = FakeBackend();
  final game = _World()..open3d(device);
  await initializeGame(() => game);
  final maze = CellGridComponent(
    grid: CellGrid.fromMask(mask),
    device: device,
    scene: game.scene,
    plane: BridgePlane.ground(),
    material: engine.Material(),
    instanced: instanced,
    hitboxes: hitboxes,
  );
  game.add(maze);
  await game.ready();
  return (game: game, maze: maze);
}

Future<(PositionComponent, GridMover)> _walker(
  _World game,
  CellGridComponent maze,
  Vector2 at, {
  bool wraps = false,
  void Function(int, int)? onArrive,
}) async {
  final mover = GridMover(
    grid: maze,
    speed: 2.0,
    wraps: wraps,
    onArrive: onArrive,
  );
  final body = PositionComponent(position: at)..add(mover);
  game.add(body);
  await game.ready();
  return (body, mover);
}

void main() {
  const maze = <String>['#####', '#...#', '#.#.#', '#...#', '#####'];

  test('a turn asked for early is taken at the first junction open to it, '
      'and a wall stops it', () async {
    // Mutation: take the wanted turn only if it is open where the mover
    // stands when asked.
    final (:game, maze: grid) = await _maze(maze);
    final arrived = <(int, int)>[];
    final (body, mover) = await _walker(
      game,
      grid,
      Vector2(1.4, 1.6),
      onArrive: (c, r) => arrived.add((c, r)),
    );
    expect(body.position, Vector2(1.5, 1.5), reason: 'stood in its cell');

    mover.wanted = GridHeading.right;
    game.update(0.25);
    expect(body.position.x, closeTo(2.0, 1e-9));

    // Down is a wall under the next cell: kept until the corner.
    mover.wanted = GridHeading.down;
    for (var i = 0; i < 4; i++) {
      game.update(0.25);
    }
    expect(body.position.x, closeTo(3.5, 1e-9));
    expect(body.position.y, closeTo(2.0, 1e-9));
    expect(mover.heading, GridHeading.down);

    for (var i = 0; i < 8; i++) {
      game.update(0.25);
    }
    expect(body.position, Vector2(3.5, 3.5), reason: 'the wall stopped it');
    expect(mover.heading, GridHeading.none);
    expect(arrived, <(int, int)>[(2, 1), (3, 1), (3, 2), (3, 3)]);
  });

  test('a turn back is taken at once, between cells', () async {
    final (:game, maze: grid) = await _maze(maze);
    final (body, mover) = await _walker(game, grid, Vector2(1.5, 1.5));
    mover.wanted = GridHeading.right;
    game.update(0.25);
    mover.wanted = GridHeading.left;
    game.update(0.125);
    expect(body.position.x, closeTo(1.75, 1e-9));
    expect(mover.heading, GridHeading.left);
  });

  test('through the tunnel, off one edge and in at the other', () async {
    // Mutation: stop at the grid's edge whatever wraps says.
    final (:game, maze: grid) = await _maze(<String>['#####', '.....']);
    final (body, mover) = await _walker(
      game,
      grid,
      Vector2(0.5, 1.5),
      wraps: true,
    );
    mover.wanted = GridHeading.left;
    game.update(0.5);
    expect(mover.cell, (4, 1));
    expect(body.position.x, closeTo(4.5, 1e-9));
  });

  test('drawn as instances, a cell taken is a slot given back', () async {
    // Mutation: rebuild a merged mesh in instanced mode.
    final (:game, maze: grid) = await _maze(maze, instanced: true);
    final batch = grid.node.childrenView.whereType<InstancedMeshNode>().single;
    expect(batch.count, grid.grid.count);
    final before = batch.count;

    expect(grid.hitAt(Vector2(2.5, 2.5), radius: 0.3), isTrue);
    expect(batch.count, before - 1);
    expect(grid.setCell(1, 1), isTrue);
    expect(batch.count, before);
    expect(
      grid.node.childrenView
          .whereType<MeshNode>()
          .whereType<InstancedMeshNode>(),
      hasLength(1),
      reason: 'no merged mesh beside the batch',
    );
  });

  test("with hitboxes, Flame's own collision meets a cell, and not one "
      'taken away', () async {
    // Mutation: one hitbox round the whole grid.
    final (:game, maze: grid) = await _maze(maze, hitboxes: true);
    expect(
      grid.children.whereType<RectangleHitbox>(),
      hasLength(grid.grid.count),
    );
    final ball = _Ball(Vector2(2.5, 2.5));
    game.add(ball);
    await game.ready();
    game.update(0.0);
    expect(ball.touched, contains(grid));

    grid.hitAt(Vector2(2.5, 2.5), radius: 0.3);
    await game.ready();
    ball.touched.clear();
    game.update(0.0);
    expect(ball.touched, isEmpty, reason: 'the cell under it went');
  });
}

final class _Ball extends PositionComponent with CollisionCallbacks {
  _Ball(Vector2 at)
    : super(
        position: at,
        size: Vector2.all(0.4),
        anchor: Anchor.center,
        children: <Component>[CircleHitbox()],
      );

  final Set<PositionComponent> touched = <PositionComponent>{};

  @override
  void onCollision(List<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    touched.add(other);
  }
}
