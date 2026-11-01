import 'dart:math';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Component3D', () {
    testWithFlameGame(
      'aabb of a nested component follows its parent when it moves',
      (game) async {
        final child = _Box(position: Vector3(1, 0, 0));
        final parent = _Group(children: [child]);
        await game.world.ensureAdd(parent);

        expect(child.aabb.center, closeToVector3(Vector3(1, 0, 0)));
        expect(parent.aabb.center, closeToVector3(Vector3(1, 0, 0)));

        parent.position.setValues(10, 0, 0);

        expect(child.aabb.center, closeToVector3(Vector3(11, 0, 0)));
        expect(parent.aabb.center, closeToVector3(Vector3(11, 0, 0)));
      },
    );

    testWithFlameGame(
      'aabb of a deeply nested component follows its ancestors',
      (game) async {
        final leaf = _Box();
        final root = _Group(
          children: [
            _Group(
              position: Vector3(0, 1, 0),
              children: [
                _Group(position: Vector3(0, 0, 1), children: [leaf]),
              ],
            ),
          ],
        );
        await game.world.ensureAdd(root);

        expect(leaf.aabb.center, closeToVector3(Vector3(0, 1, 1)));

        root.position.setValues(1, 0, 0);

        expect(leaf.aabb.center, closeToVector3(Vector3(1, 1, 1)));
        expect(root.aabb.center, closeToVector3(Vector3(1, 1, 1)));
      },
    );

    testWithFlameGame(
      'aabb of a nested component follows its ancestors after repeated moves',
      (game) async {
        final leaf = _Box();
        final middle = _Group(children: [leaf]);
        final root = _Group(children: [middle]);
        await game.world.ensureAdd(root);

        // Only read the leaf in between the moves, so that the ancestors'
        // AABBs stay dirty while the leaf's is recomputed.
        root.position.setValues(1, 0, 0);
        expect(leaf.aabb.center, closeToVector3(Vector3(1, 0, 0)));

        root.position.setValues(2, 0, 0);
        expect(leaf.aabb.center, closeToVector3(Vector3(2, 0, 0)));

        middle.position.setValues(0, 1, 0);
        expect(leaf.aabb.center, closeToVector3(Vector3(2, 1, 0)));
        expect(root.aabb.center, closeToVector3(Vector3(2, 1, 0)));
      },
    );

    testWithFlameGame(
      'aabb of a parent follows its child when the child moves',
      (game) async {
        final child = _Box();
        final parent = _Group(children: [child]);
        await game.world.ensureAdd(parent);

        expect(parent.aabb.center, closeToVector3(Vector3.zero()));

        child.position.setValues(5, 0, 0);

        expect(parent.aabb.center, closeToVector3(Vector3(5, 0, 0)));
      },
    );

    testWithFlameGame(
      'aabb of a parent includes a child added after it was computed',
      (game) async {
        final parent = _Group(children: [_Box()]);
        await game.world.ensureAdd(parent);

        expect(parent.aabb.max, closeToVector3(Vector3.all(0.5)));

        await parent.ensureAdd(_Box(position: Vector3(10, 0, 0)));

        expect(parent.aabb.max, closeToVector3(Vector3(10.5, 0.5, 0.5)));
      },
    );

    testWithFlameGame(
      'aabb of an ancestor includes a deeply nested child added later',
      (game) async {
        final middle = _Group(children: [_Box()]);
        final root = _Group(children: [middle]);
        await game.world.ensureAdd(root);

        expect(root.aabb.max, closeToVector3(Vector3.all(0.5)));

        await middle.ensureAdd(_Box(position: Vector3(0, 10, 0)));

        expect(root.aabb.max, closeToVector3(Vector3(0.5, 10.5, 0.5)));
      },
    );

    testWithFlameGame(
      'aabb of a parent shrinks when a child is removed',
      (game) async {
        final child = _Box(position: Vector3(10, 0, 0));
        final parent = _Group(children: [_Box(), child]);
        await game.world.ensureAdd(parent);

        expect(parent.aabb.max, closeToVector3(Vector3(10.5, 0.5, 0.5)));

        parent.remove(child);
        await game.ready();

        expect(parent.aabb.max, closeToVector3(Vector3.all(0.5)));
      },
    );

    testWithFlameGame(
      'aabb of a component without geometry is at its position',
      (game) async {
        final component = _Empty(position: Vector3(1, 2, 3));
        await game.world.ensureAdd(component);

        expect(component.aabb.min, closeToVector3(Vector3(1, 2, 3)));
        expect(component.aabb.max, closeToVector3(Vector3(1, 2, 3)));
      },
    );

    testWithFlameGame(
      'aabb of a nested component without geometry is at its world position',
      (game) async {
        final child = _Empty(position: Vector3(0, 1, -20));
        final parent = _Group(
          position: Vector3(0, 0, 25),
          children: [child],
        );
        await game.world.ensureAdd(parent);

        expect(child.aabb.min, closeToVector3(Vector3(0, 1, 5)));
        expect(child.aabb.max, closeToVector3(Vector3(0, 1, 5)));
      },
    );

    testWithFlameGame(
      'aabb of a component without geometry follows the rotation and scale of '
      'its parent',
      (game) async {
        final child = _Empty(position: Vector3(1, 0, 0));
        final parent = _Group(
          position: Vector3(0, 0, 5),
          rotation: Quaternion.axisAngle(Vector3(0, 1, 0), pi / 2),
          scale: Vector3.all(2),
          children: [child],
        );
        await game.world.ensureAdd(parent);

        // Scaled to (2, 0, 0), rotated to (0, 0, -2) and moved to (0, 0, 3).
        expect(child.aabb.min, closeToVector3(Vector3(0, 0, 3), 1e-6));
        expect(child.aabb.max, closeToVector3(Vector3(0, 0, 3), 1e-6));
      },
    );

    testWithFlameGame(
      'aabb of a group is at the world position of its descendants without '
      'geometry',
      (game) async {
        final root = _Group(
          position: Vector3(10, 0, 0),
          children: [
            _Group(
              position: Vector3(0, 1, 0),
              children: [_Empty(position: Vector3(0, 0, 1))],
            ),
          ],
        );
        await game.world.ensureAdd(root);

        expect(root.aabb.min, closeToVector3(Vector3(10, 1, 1)));
        expect(root.aabb.max, closeToVector3(Vector3(10, 1, 1)));
      },
    );
  });
}

class _Group({
  super.position,
  super.rotation,
  super.scale,
  super.children,
}) extends Component3D;

class _Box({super.position}) extends Object3D {
  @override
  Aabb3? computeLocalAabb() =>
      Aabb3.minMax(Vector3.all(-0.5), Vector3.all(0.5));

  @override
  void draw(RenderContext context) {}
}

class _Empty({super.position}) extends Object3D {
  @override
  void draw(RenderContext context) {}
}
