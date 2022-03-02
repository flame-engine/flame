import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('IdentityProjector', () {
    test('basic properties', () {
      final projector = IdentityProjector();
      checkProjectorReversibility(projector);
      final v = Vector2(3.14, -3.15);
      expect(projector.projectVector(v), closeToVector(v.x, v.y));
      expect(projector.scaleVector(v), closeToVector(v.x, v.y));
    });
  });

  group('ComposedProjector', () {
    test('compose 2 projectors', () {
      final projector = ComposedProjector([
        _ScaleProjector(3),
        _ScaleProjector(-1),
      ]);
      checkProjectorReversibility(projector);
      expect(projector.projectVector(Vector2(4, 5)), closeToVector(-12, -15));
      expect(projector.projectVector(Vector2(1, -2)), closeToVector(-3, 6));
    });
  });
}

/// This function verifies that for the given [projector], its `project` and
/// `unproject` methods are the inverses of one another.
void checkProjectorReversibility(Projector projector) {
  final random = Random();
  for (var i = 0; i < 10; i++) {
    final point = Vector2(
      random.nextDouble() * exp(random.nextDouble().abs() * 2),
      random.nextDouble() * exp(random.nextDouble().abs() * 2),
    );
    expect(
      projector.projectVector(projector.unprojectVector(point)),
      closeToVector(point.x, point.y, epsilon: 1e-13),
    );
    expect(
      projector.unprojectVector(projector.projectVector(point)),
      closeToVector(point.x, point.y, epsilon: 1e-13),
    );
    expect(
      projector.scaleVector(projector.unscaleVector(point)),
      closeToVector(point.x, point.y, epsilon: 1e-13),
    );
    expect(
      projector.unscaleVector(projector.scaleVector(point)),
      closeToVector(point.x, point.y, epsilon: 1e-13),
    );
  }
}

class _ScaleProjector extends Projector {
  _ScaleProjector(this.scale);
  final double scale;

  @override
  Vector2 projectVector(Vector2 p) => p.scaled(scale);

  @override
  Vector2 scaleVector(Vector2 p) => p.scaled(scale);

  @override
  Vector2 unprojectVector(Vector2 p) => p.scaled(1 / scale);

  @override
  Vector2 unscaleVector(Vector2 p) => p.scaled(1 / scale);
}
