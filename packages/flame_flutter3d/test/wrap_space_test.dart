/// A world whose edges meet: positions wrap, a craft by an edge is drawn on
/// the other side too, and it can be hit across the seam.
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d_physics/flutter3d_physics.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Game extends FlameGame with HasCollisionDetection {}

final class _Rock extends Object3dComponent with CollisionCallbacks {
  _Rock(Scene scene, Vector2 at)
    : super(
        node: MeshNode(
          CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
          engine.Material(),
        ),
        scene: scene,
        plane: BridgePlane.ground(),
        direction: SyncDirection.flameToScene,
        position: at,
        size: Vector2.all(1.0),
        anchor: Anchor.center,
        children: <Component>[RectangleHitbox()],
      );

  PositionComponent? hitBy;
  int starts = 0;

  @override
  void onCollisionStart(List<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    hitBy = other;
    starts++;
  }
}

WrapSpace _space(Scene scene) => WrapSpace(
  min: Vector2(-10.0, -10.0),
  max: Vector2(10.0, 10.0),
  scene: scene,
);

void main() {
  testWithGame<_Game>(
    'what leaves by one edge comes back by the other',
    _Game.new,
    (game) async {
      final scene = Scene();
      final space = _space(scene);
      final rock = _Rock(scene, Vector2(10.5, -3.0));
      space.add(rock);
      game.add(space);
      await game.ready();
      game.update(1 / 60);
      expect(rock.position.x, closeTo(-9.5, 1e-9));
      expect(
        space.shortestWay(Vector2(9.0, 0.0), Vector2(-9.0, 0.0)).x,
        closeTo(2.0, 1e-9),
      );
    },
  );

  testWithGame<_Game>(
    'a rock by the edge is drawn on the other side as well',
    _Game.new,
    (game) async {
      // Mutation: draw no ghost; the rock blinks from side to side.
      final scene = Scene();
      final space = _space(scene);
      final rock = _Rock(scene, Vector2(9.7, 0.0));
      space.add(rock);
      game.add(space);
      await game.ready();
      game.update(1 / 60);

      final xs = <double>[
        for (final node in scene.root.childrenView) node.readPosition().x,
      ]..sort();
      expect(xs.first, closeTo(9.7 - 20.0, 1e-4), reason: 'the ghost');
      expect(xs.last, closeTo(9.7, 1e-4), reason: 'the rock');
    },
  );

  testWithGame<_Game>(
    'a shot on one side hits a rock on the other, across the seam',
    _Game.new,
    (game) async {
      // Mutation: give the ghosts no hitboxes.
      final scene = Scene();
      final space = _space(scene);
      final rock = _Rock(scene, Vector2(9.8, 0.0));
      final shot = _Rock(scene, Vector2(-9.9, 0.0));
      space.addAll(<Component>[rock, shot]);
      game.add(space);
      await game.ready();
      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
        await game.ready();
      }
      expect(rock.hitBy, same(shot));
    },
  );

  for (final (name, a, b) in <(String, Vector2, Vector2)>[
    ('by the same edge', Vector2(9.6, 0.0), Vector2(9.9, 0.3)),
    ('across the seam', Vector2(9.8, 0.0), Vector2(-9.9, 0.0)),
    ('in opposite corners', Vector2(9.8, 9.8), Vector2(-9.9, -9.9)),
  ]) {
    testWithGame<_Game>('two rocks $name are told they met once', _Game.new, (
      game,
    ) async {
      // Two by the same edge met really and through their ghosts, two across
      // the seam through each one's ghost, and every hit counted twice.
      //
      // Mutation: let ghosts meet ghosts, and both mirrored ghosts meet.
      final scene = Scene();
      final space = _space(scene);
      final first = _Rock(scene, a);
      final second = _Rock(scene, b);
      space.addAll(<Component>[first, second]);
      game.add(space);
      await game.ready();
      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
        await game.ready();
      }
      expect(first.starts, 1);
      expect(second.starts, 1);
    });
  }

  testWithGame<_Game>(
    'a body the physics moves is carried across the edge, still moving',
    _Game.new,
    (game) async {
      // Its Flame position was wrapped and read straight back from the body
      // on the far side, and it flew on out of the world.
      //
      // Mutation: wrap the Flame position alone.
      final world = CollisionWorld();
      final body = RigidBody(
        world: world,
        shape: CollisionBox(Vector3.all(0.4)),
        position: Vector3(10.5, 0.0, -3.0),
      )..velocity.setValues(4.0, 0.0, 0.0);
      final ship = RigidBodyComponent(
        body: body,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
      );
      final space = _space(ship.scene);
      space.add(ship);
      game.add(space);
      await game.ready();
      game
        ..update(1 / 60)
        ..update(1 / 60);

      expect(body.position.x, closeTo(-9.5, 1e-6));
      expect(ship.position.x, closeTo(-9.5, 1e-6));
      expect(body.velocity.x, 4.0, reason: 'carried, not stopped');
    },
  );

  testWithGame<_Game>(
    "a passive rock's ghost is passive, and a polygon stays a polygon",
    _Game.new,
    (game) async {
      final scene = Scene();
      final space = _space(scene);
      final rock = _Rock(scene, Vector2(9.7, 0.0));
      rock.children.whereType<RectangleHitbox>().single.collisionType =
          CollisionType.passive;
      rock.add(
        PolygonHitbox(<Vector2>[
          Vector2(0.0, 0.0),
          Vector2(1.0, 0.0),
          Vector2(0.5, 1.0),
        ]),
      );
      space.add(rock);
      game.add(space);
      await game.ready();
      game.update(1 / 60);
      await game.ready();

      final hitboxes = rock.children.whereType<ShapeHitbox>().toList();
      expect(hitboxes, hasLength(4), reason: 'two, and a ghost of each');
      expect(
        hitboxes.whereType<PolygonHitbox>(),
        hasLength(2),
        reason: 'the ghost of a triangle is a triangle',
      );
      expect(
        hitboxes.whereType<RectangleHitbox>().map((h) => h.collisionType),
        everyElement(CollisionType.passive),
      );
    },
  );
}
