import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

import 'collision_test_helpers.dart';

void main() {
  group('ShapeHitbox re-added', () {
    testCollisionDetectionGame(
      'follows the moves of its parent while it was removed',
      (game) async {
        // With a size, so that the hitbox does not fill its parent when
        // mounted, which would compute its bounds again as a side effect.
        final hitbox = RectangleHitbox(size: Vector2.all(10));
        final parent = PositionComponent(
          size: Vector2.all(10),
          children: [hitbox],
        );
        final block = TestBlock(Vector2(105, 0), Vector2.all(10));
        await game.ensureAddAll([parent, block]);
        expect(hitbox.aabb.min.x, closeTo(0, 1e-9));

        parent.remove(hitbox);
        await game.ready();
        parent.position.setValues(100, 0);
        parent.add(hitbox);
        await game.ready();
        game.update(0);

        expect(hitbox.aabb.min.x, closeTo(100, 1e-9));
        final ray = Ray2(origin: Vector2(102, -10), direction: Vector2(0, 1));
        expect(game.collisionDetection.raycast(ray)?.hitbox, hitbox);
        expect(block.startCounter, 1);
      },
    );

    testCollisionDetectionGame(
      'does not grow its list of ancestors each time it is mounted',
      (game) async {
        final hitbox = RectangleHitbox();
        final parent = _CountingParent(children: [hitbox]);
        await game.ensureAdd(parent);
        for (var mounts = 1; mounts <= 3; mounts++) {
          parent.transform.removed = 0;
          parent.remove(hitbox);
          await game.ready();
          expect(parent.transform.removed, 1, reason: 'removal $mounts');
          parent.add(hitbox);
          await game.ready();
        }
      },
    );
  });
}

/// Counts the listeners removed from the transform.
class _CountingTransform2D() extends Transform2D {
  int removed = 0;

  @override
  void removeListener(void Function() listener) {
    removed++;
    super.removeListener(listener);
  }
}

class _CountingParent({super.children}) extends PositionComponent {
  this : super(size: Vector2.all(10));

  final _transform = _CountingTransform2D();

  @override
  _CountingTransform2D get transform => _transform;
}
