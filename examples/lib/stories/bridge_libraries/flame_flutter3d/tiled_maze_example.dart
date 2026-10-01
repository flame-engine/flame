import 'dart:math' as math;

import 'package:examples/stories/bridge_libraries/flame_flutter3d/story_host.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:tiled/tiled.dart';

class TiledMazeExample extends FlameGame
    with HasFlutter3d, HasCollisionDetection {
  static const String description = '''
    A maze drawn in the Tiled editor and stood up in 3D by `TiledWorld3d`.
    Each tile layer becomes a grid of blocks set up by its custom properties
    in Tiled: the walls are tall and solid, so they get Flame hitboxes, the
    floor is merged into one mesh, and the dots float above it.

    The player is the map's one object. A `GridMover` walks it from the
    middle of one cell to the next, turning at random at the junctions and
    eating the dots, while the camera circles the maze.
  ''';

  static final BridgePlane _plane = BridgePlane.ground();
  final math.Random _random = math.Random(4);

  late final TiledMap _map;
  late final Vector3 _centre;
  double _time = 0;

  @override
  CameraNode createCamera3d() => CameraNode(
    name: 'camera',
    projection: const PerspectiveProjection(fovYRadians: 0.8, far: 200),
  );

  @override
  Future<void> onLoad() async {
    _map = TiledMap.parseTmx(await assets.readFile('assets/tiles/maze_3d.tmx'));
    await super.onLoad();
  }

  @override
  void onOpen3d() {
    clearColor.setValues(0.04, 0.04, 0.08, 1);
    scene.add(
      LightNode(intensity: 2.5)..setLocalForward(Vector3(-0.3, -1, -0.5)),
    );
    _centre = _plane.to3d(Vector2(_map.width / 2, _map.height / 2));

    late final TiledWorld3d level;
    level = TiledWorld3d(
      map: _map,
      device: device,
      scene: scene,
      plane: _plane,
      material: (layer) => engine.Material(
        name: layer.name,
        roughness: layer.name == 'walls' ? 0.35 : 0.8,
        metallic: layer.name == 'walls' ? 0.4 : 0,
      ),
      spawn: (object, at) =>
          object.name == 'player' ? _player(level, at) : null,
    );
    addAll([
      level,
      TextComponent(
        text: 'Drawn with ${backendName(device)}',
        position: Vector2.all(16),
      ),
    ]);
  }

  PositionComponent _player(TiledWorld3d level, Vector2 at) {
    final walls = level.grids['walls']!;
    final dots = level.grids['dots']!;
    late final GridMover mover;
    mover = GridMover(
      grid: walls,
      speed: 3,
      onArrive: (column, row) {
        dots.setCell(column, row, alive: false);
        mover.wanted = _turnAt(walls, column, row, mover.heading);
      },
    )..wanted = GridHeading.left;
    return Object3dComponent(
      node: MeshNode(
        DeviceMesh.upload(device, const SphereShape(radius: 0.35).build()),
        engine.Material(
          name: 'player',
          baseColor: Vector4(1, 0.85, 0.2, 1),
          emissive: Vector3(1, 0.7, 0.1),
          emissiveStrength: 2,
        ),
      ),
      scene: scene,
      plane: _plane,
      direction: SyncDirection.flameToScene,
      elevation: 0.35,
      position: at,
      size: Vector2.all(0.7),
      anchor: Anchor.center,
      children: [CircleHitbox(), mover],
    );
  }

  /// A way open from the cell, not straight back unless it is a dead end.
  GridHeading _turnAt(
    CellGridComponent walls,
    int column,
    int row,
    GridHeading heading,
  ) {
    final open = [
      for (final way in GridHeading.values)
        if (way != GridHeading.none &&
            !walls.grid.isAlive(column + way.dx, row + way.dy))
          way,
    ];
    final onward = open.where((way) => way != heading.opposite).toList();
    final choices = onward.isEmpty ? open : onward;
    return choices.isEmpty
        ? GridHeading.none
        : choices[_random.nextInt(choices.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!has3d) {
      return;
    }
    _time += dt;
    final angle = _time * 0.25;
    camera3d
      ..setPosition(
        _centre.x + 9 * math.cos(angle),
        9,
        _centre.z + 9 * math.sin(angle),
      )
      ..lookAt(_centre);
  }
}
