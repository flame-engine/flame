import 'package:flame/src/game/notifying_vector2.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

typedef VectorOperation = void Function(Vector2);

/// This helper function creates a "normal" Vector2 copy of [v1],
/// then applies [operation] to both vectors, and verifies that the
/// end result is the same. It also checks that [v1] produces a
/// notification during a modifying operation.
void check(NotifyingVector2 v1, VectorOperation operation) {
  final v2 = v1.clone();
  expect(v2 is Vector2, true);
  expect(v2 is NotifyingVector2, false);
  var notified = 0;
  void listener() {
    notified++;
  }

  v1.addListener(listener);
  operation(v1);
  operation(v2);
  v1.removeListener(listener);
  expect(notified, 1);
  expect(v1, v2);
}

void main() {
  group('NotifyingVector2', () {
    test('constructors', () {
      final nv0 = NotifyingVector2.zero();
      expect(nv0, Vector2.zero());
      final nv1 = NotifyingVector2(3, 1415);
      expect(nv1, Vector2(3, 1415));
      final nv2 = NotifyingVector2.all(111);
      expect(nv2, Vector2.all(111));
      final nv3 = NotifyingVector2.copy(Vector2(4, 9));
      expect(nv3, Vector2(4, 9));
    });
    test('full setters', () {
      final nv = NotifyingVector2.zero();
      check(nv, (v) => v.setValues(3, 2));
      check(nv, (v) => v.setFrom(Vector2(5, 8)));
      check(nv, (v) => v.setZero());
      check(nv, (v) => v.splat(3.2));
      check(nv, (v) => v.copyFromArray([1, 2, 3, 4, 5]));
      check(nv, (v) => v.copyFromArray([1, 2, 3, 4, 5], 2));
      check(nv, (v) => v.xy = Vector2(7, 2));
      check(nv, (v) => v.yx = Vector2(7, 2));
      check(nv, (v) => v.rg = Vector2(1, 10));
      check(nv, (v) => v.gr = Vector2(1, 10));
      check(nv, (v) => v.st = Vector2(-5, -89));
      check(nv, (v) => v.ts = Vector2(-5, -89));
    });
    test('individual field setters', () {
      final nv = NotifyingVector2.zero();
      check(nv, (v) => v[0] = 2.5);
      check(nv, (v) => v[1] = 1.25);
      check(nv, (v) => v.x = 425);
      check(nv, (v) => v.y = -1.11e-11);
      check(nv, (v) => v.r = 101);
      check(nv, (v) => v.g = 102);
      check(nv, (v) => v.s = 103);
      check(nv, (v) => v.t = 104);
    });
    test('modification methods', () {
      final nv = NotifyingVector2(23, 3);
      check(nv, (v) => v.length = 15);
      check(nv, (v) => v.normalize());
      check(nv, (v) => v.postmultiply(Matrix2.rotation(1)));
      check(nv, (v) => v.add(Vector2(0.2, -0.1)));
      check(nv, (v) => v.addScaled(Vector2(2.05, 1.1), 3));
      check(nv, (v) => v.sub(Vector2(9.7, 4.62)));
      check(nv, (v) => v.multiply(Vector2(1.2, -0.62)));
      check(nv, (v) => v.divide(Vector2(0.69, 1.23)));
      check(nv, (v) => v.scale(7.802));
      check(nv, (v) => v.negate());
      check(nv, (v) => v.absolute());
      check(nv, (v) => v.clamp(Vector2(-5, -6), Vector2(100, 1e20)));
      check(nv, (v) => v.clampScalar(-2, 38479.10349));
      check(nv, (v) => v.floor());
      nv.scale(1.3891);
      check(nv, (v) => v.ceil());
      nv.scale(1.111);
      check(nv, (v) => v.round());
      nv.multiply(Vector2(1.23, -4.791));
      check(nv, (v) => v.roundToZero());
    });
    test('storage is read-only', () {
      final nv = NotifyingVector2.zero();
      expect(nv, Vector2.zero());
      final storage = nv.storage;
      // Check that storage is not writable
      expect(
        () {
          storage[0] = 1;
        },
        throwsA(isA<UnsupportedError>()),
      );
      // Check that the vector wasn't modified, and that storage is readable
      expect(storage[0], 0);
      expect(storage[1], 0);
    });
  });
}
