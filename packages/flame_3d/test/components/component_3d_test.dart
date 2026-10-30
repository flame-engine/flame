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
  });
}

class _Group({super.position, super.children}) extends Component3D;

class _Box({super.position}) extends Object3D {
  @override
  Aabb3? computeLocalAabb() =>
      Aabb3.minMax(Vector3.all(-0.5), Vector3.all(0.5));

  @override
  void draw(RenderContext context) {}
}
