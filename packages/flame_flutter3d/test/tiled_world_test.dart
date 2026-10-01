/// A level drawn in Tiled, stood up in 3D and walked.
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d_hardware/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiled/tiled.dart';

final class _World extends FlameGame with HasFlutter3d, HasCollisionDetection {}

/// A five by five maze of 16-pixel tiles: a solid wall layer, a layer of
/// dots, and the player as a point.
const String _level = '''
<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" orientation="orthogonal" renderorder="right-down"
     width="5" height="5" tilewidth="16" tileheight="16" infinite="0">
 <tileset firstgid="1" name="maze" tilewidth="16" tileheight="16"
          tilecount="2" columns="2"/>
 <layer id="1" name="walls" width="5" height="5" tintcolor="#3050ff">
  <properties>
   <property name="solid" type="bool" value="true"/>
   <property name="depth" type="float" value="0.5"/>
  </properties>
  <data encoding="csv">
1,1,1,1,1,
1,0,0,0,1,
1,0,1,0,1,
1,0,0,0,1,
1,1,1,1,1
</data>
 </layer>
 <layer id="2" name="dots" width="5" height="5">
  <data encoding="csv">
0,0,0,0,0,
0,0,2,2,0,
0,0,0,2,0,
0,2,2,2,0,
0,0,0,0,0
</data>
 </layer>
 <objectgroup id="3" name="actors">
  <object id="1" name="player" x="24" y="24">
   <point/>
  </object>
 </objectgroup>
</map>
''';

void main() {
  test('each tile layer is a grid of blocks where its tiles are, set up by '
      "its properties, and each object is the game's", () async {
    // Mutation: read every layer as walls, or leave the objects out.
    final device = FakeBackend();
    final game = _World()..open3d(device);
    await initializeGame(() => game);
    final spawned = <String, Vector2>{};
    PositionComponent? player;
    final level = TiledWorld3d(
      map: TiledMap.parseTmx(_level),
      device: device,
      scene: game.scene,
      plane: BridgePlane.ground(),
      material: (_) => engine.Material(),
      spawn: (object, at) {
        spawned[object.name] = at.clone();
        return player = PositionComponent(position: at);
      },
    );
    game.add(level);
    await game.ready();

    final walls = level.grids['walls']!;
    final dots = level.grids['dots']!;
    expect(walls.grid.count, 17);
    expect(walls.grid.isAlive(2, 2), isTrue);
    expect(walls.grid.isAlive(1, 1), isFalse);
    expect(walls.hitboxes, isTrue, reason: 'solid in Tiled');
    expect(walls.children.whereType<RectangleHitbox>(), hasLength(17));
    expect(walls.depth, 0.5);
    expect(walls.colour!.z, closeTo(1.0, 1e-9), reason: 'its tint');
    expect(dots.hitboxes, isFalse);
    expect(dots.grid.count, 6);
    expect(spawned['player'], Vector2(1.5, 1.5));

    // The player walks the maze Tiled drew, eating the dots it reaches.
    final mover = GridMover(
      grid: walls,
      speed: 4.0,
      onArrive: (c, r) => dots.setCell(c, r, alive: false),
    )..wanted = GridHeading.right;
    player!.add(mover);
    await game.ready();
    game.update(0.5);
    expect(mover.cell, (3, 1));
    expect(dots.grid.isAlive(2, 1), isFalse, reason: 'eaten');
    expect(dots.grid.count, 4);
  });
}
