import 'package:flame/src/game/notifying_vector2.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

typedef VectorOperation = void Function(Vector2);

void check(NotifyingVector2 v1, VectorOperation operation) {
  final v2 = v1.clone();
  var notified = 0;
  void listener () {
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
    test('full setters', () {
      final nv = NotifyingVector2();
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
    test('field setters', () {
      final nv = NotifyingVector2();
      check(nv, (v) => v[0] = 2.5);
      check(nv, (v) => v[1] = 1.25);
      check(nv, (v) => v.x = 425);
      check(nv, (v) => v.y = -1.11e-11);
      check(nv, (v) => v.r = 101);
      check(nv, (v) => v.g = 102);
      check(nv, (v) => v.s = 103);
      check(nv, (v) => v.t = 104);
    });
    test('methods', () {
      final nv = NotifyingVector2() ..setValues(23, 3);
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
    test('storage', () {
      final nv = NotifyingVector2();
      expect(() => nv.storage, throwsA(isA<UnsupportedError>()));
    });
  });
}
