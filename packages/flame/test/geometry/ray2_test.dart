import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/experimental/geometry/shapes/circle.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Ray2', () {
    test('Properly updates direction inverses', () {
      final direction = Vector2(-10.0, 3).normalized();
      final ray = Ray2(
        Vector2.all(2.0),
        direction,
      );
      expect(
        ray.directionInvX,
        1 / direction.x,
        reason: 'The inverse of the x-direction is wrong',
      );
      expect(
        ray.directionInvY,
        1 / direction.y,
        reason: 'The inverse of the y-direction is wrong',
      );
      final updatedDirection = Vector2(10, 4).normalized();
      ray.direction = updatedDirection;
      expect(
        ray.directionInvX,
        1 / updatedDirection.x,
        reason: 'The inverse of the x-direction did not properly update',
      );
      expect(
        ray.directionInvY,
        1 / updatedDirection.y,
        reason: 'The inverse of the y-direction did not properly update',
      );
    });

    test('Throws assertion if direction is not normalized', () {
      final direction = Vector2(1.01, 0.0);
      expect(
        () {
          Ray2(
            Vector2.all(2.0),
            direction,
          );
        },
        failsAssert('direction must be normalized'),
      );
      final ray = Ray2(Vector2.all(2.0), direction.normalized());
      expect(
        () => ray.direction = direction,
        failsAssert('direction must be normalized'),
      );
    });

    group('intersectsWithAabb2', () {
      test('Ray from the east', () {
        final direction = Vector2(1.0, 0.0);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(1, -1), Vector2(2, 1))),
          isTrue,
        );
      });

      test('Ray from the north', () {
        final direction = Vector2(0.0, 1.0);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(-1, 1), Vector2(1, 2))),
          isTrue,
        );
      });

      test('Ray from the west', () {
        final direction = Vector2(-1.0, 0.0);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(
              Aabb2.minMax(Vector2(-2, -1), Vector2(-1, 1))),
          isTrue,
        );
      });

      test('Ray from the south', () {
        final direction = Vector2(0.0, -1.0);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(
              Aabb2.minMax(Vector2(-1, -2), Vector2(1, -1))),
          isTrue,
        );
      });

      test('Ray from the northEast', () {
        final direction = Vector2(0.5, 0.5);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(1, 1), Vector2(2, 2))),
          isTrue,
        );
      });

      test('Ray from the northWest', () {
        final direction = Vector2(-0.5, 0.5);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(-2, 1), Vector2(-1, 2))),
          isTrue,
        );
      });

      test('Ray from the southWest', () {
        final direction = Vector2(-0.5, -0.5);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(
            Aabb2.minMax(Vector2(-2, -2), Vector2(-1, -1)),
          ),
          isTrue,
        );
      });

      test('Ray from the southEast', () {
        final direction = Vector2(0.5, -0.5);
        final ray = Ray2(Vector2.zero(), direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(1, -2), Vector2(2, -1))),
          isTrue,
        );
      });

      test(
        'Ray that originates from within the box',
        () {
          final direction = Vector2(0, 1);
          const numberOfDirections = 16;
          for (var i = 0; i < numberOfDirections; i++) {
            direction.rotate(tau * (i / numberOfDirections));
            final ray = Ray2(Vector2.all(5), direction.normalized());
            final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
            expect(
              ray.intersectsWithAabb2(aabb2),
              isTrue,
            );
          }
        },
      );

      test(
        'Ray that originates from a box edge',
        () {
          final direction = Vector2(-1, 0);
          const numberOfDirections = 16;
          for (var i = 0; i < numberOfDirections; i++) {
            final angle = tau * (i / numberOfDirections);
            direction.rotate(angle);
            final ray = Ray2(Vector2(10, 5), direction.normalized());
            final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
            expect(
              ray.intersectsWithAabb2(aabb2),
              isTrue,
            );
          }
        },
      );

      // https://tavianator.com/2015/ray_box_nan.html
      test(
        'Rays that originates and follows a box edge does not intersect',
        () {
          final rayVertical = Ray2(Vector2(10, 5), Vector2(0, 1));
          final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
          expect(
            rayVertical.intersectsWithAabb2(aabb2),
            isFalse,
          );
          final rayHorizontal = Ray2(Vector2(5, 0), Vector2(1, 0));
          expect(
            rayHorizontal.intersectsWithAabb2(aabb2),
            isFalse,
          );
        },
      );

      test(
        'Ray in the opposite direction does not intersect',
        () {
          final direction = Vector2(1, 0);
          final ray = Ray2(Vector2(15, 5), direction.normalized());
          final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
          expect(
            ray.intersectsWithAabb2(aabb2),
            isFalse,
          );
        },
      );
    });

    group('lineSegmentIntersection', () {
      test(
        'Correct intersection point length on ray going east',
        () {
          final direction = Vector2(1, 0);
          final ray = Ray2(Vector2(5, 5), direction.normalized());
          final segment = LineSegment(Vector2(10, 0), Vector2.all(10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going west',
        () {
          final direction = Vector2(-1, 0);
          final ray = Ray2(Vector2(5, 5), direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(0, 10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going south',
        () {
          final direction = Vector2(0, 1);
          final ray = Ray2(Vector2(5, 5), direction.normalized());
          final segment = LineSegment(Vector2(0, 10), Vector2(10, 10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going north',
        () {
          final direction = Vector2(0, -1);
          final ray = Ray2(Vector2(5, 5), direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point when ray originates on segment',
        () {
          final direction = Vector2(0, -1);
          final ray = Ray2(Vector2(5, 0), direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), 0);
        },
      );

      test(
        'No intersection point when ray follows the segment',
        () {
          final direction = Vector2(1, 0);
          final ray = Ray2(Vector2(5, 0), direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), null);
        },
      );
    });
  });
}
