import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Ray2', () {
    test('Properly updates direction inverses', () {
      final direction = Vector2(-10.0, 3).normalized();
      final ray = Ray2(
        origin: Vector2.all(2.0),
        direction: direction,
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
            origin: Vector2.all(2.0),
            direction: direction,
          );
        },
        failsAssert('direction must be normalized'),
      );
      final ray = Ray2(
        origin: Vector2.all(2.0),
        direction: direction.normalized(),
      );
      expect(
        () => ray.direction = direction,
        failsAssert('direction must be normalized'),
      );
    });

    group('intersectsWithAabb2', () {
      test('Ray from the east', () {
        final direction = Vector2(1.0, 0.0);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(1, -1), Vector2(2, 1))),
          isTrue,
        );
      });

      test('Ray from the north', () {
        final direction = Vector2(0.0, 1.0);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(-1, 1), Vector2(1, 2))),
          isTrue,
        );
      });

      test('Ray from the west', () {
        final direction = Vector2(-1.0, 0.0);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(
            Aabb2.minMax(Vector2(-2, -1), Vector2(-1, 1)),
          ),
          isTrue,
        );
      });

      test('Ray from the south', () {
        final direction = Vector2(0.0, -1.0);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(
            Aabb2.minMax(Vector2(-1, -2), Vector2(1, -1)),
          ),
          isTrue,
        );
      });

      test('Ray from the northEast', () {
        final direction = Vector2(0.5, 0.5);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(1, 1), Vector2(2, 2))),
          isTrue,
        );
      });

      test('Ray from the northWest', () {
        final direction = Vector2(-0.5, 0.5);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(Aabb2.minMax(Vector2(-2, 1), Vector2(-1, 2))),
          isTrue,
        );
      });

      test('Ray from the southWest', () {
        final direction = Vector2(-0.5, -0.5);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
        expect(
          ray.intersectsWithAabb2(
            Aabb2.minMax(Vector2(-2, -2), Vector2(-1, -1)),
          ),
          isTrue,
        );
      });

      test('Ray from the southEast', () {
        final direction = Vector2(0.5, -0.5);
        final ray =
            Ray2(origin: Vector2.zero(), direction: direction.normalized());
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
            final ray =
                Ray2(origin: Vector2.all(5), direction: direction.normalized());
            final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
            expect(
              ray.intersectsWithAabb2(aabb2),
              isTrue,
            );
          }
        },
      );

      test(
        'Rays that originates from a box edge pointing inwards',
        () {
          const epsilon = 0.000001;
          const numberOfDirections = 100;
          for (var i = 0; i < numberOfDirections; i++) {
            final direction = Vector2(0, 1);
            final angle =
                (tau / 2 - 2 * epsilon) * (i / numberOfDirections) + epsilon;
            direction.rotate(angle);
            final ray =
                Ray2(origin: Vector2(10, 5), direction: direction.normalized());
            final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
            expect(
              ray.intersectsWithAabb2(aabb2),
              isTrue,
            );
          }
        },
      );

      test(
        'Rays that originates from a box edge pointing outwards intersects',
        () {
          const epsilon = 0.000001;
          const numberOfDirections = 100;
          for (var i = 0; i < numberOfDirections; i++) {
            final direction = Vector2(0, 1);
            final angle =
                (tau / 2 - 2 * epsilon) * (i / numberOfDirections) + epsilon;
            direction.rotate(-angle);
            final ray =
                Ray2(origin: Vector2(10, 5), direction: direction.normalized());
            final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
            expect(
              ray.intersectsWithAabb2(aabb2),
              isTrue,
            );
          }
        },
      );

      test(
        'Rays that originates and follows a box edge does intersects',
        () {
          final rayVertical =
              Ray2(origin: Vector2(10, 5), direction: Vector2(0, 1));
          final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
          expect(
            rayVertical.intersectsWithAabb2(aabb2),
            isTrue,
          );
          final rayHorizontal =
              Ray2(origin: Vector2(5, 0), direction: Vector2(1, 0));
          expect(
            rayHorizontal.intersectsWithAabb2(aabb2),
            isTrue,
          );
        },
      );

      test(
        'Rays that originates in a corner intersects',
        () {
          final rayZero =
              Ray2(origin: Vector2.zero(), direction: Vector2(0, 1));
          final aabb2 = Aabb2.minMax(Vector2.zero(), Vector2.all(10));
          expect(
            rayZero.intersectsWithAabb2(aabb2),
            isTrue,
          );
          final rayTen =
              Ray2(origin: Vector2.all(10), direction: Vector2(0, -1));
          expect(
            rayTen.intersectsWithAabb2(aabb2),
            isTrue,
          );
        },
      );

      test(
        'Ray in the opposite direction does not intersect',
        () {
          final direction = Vector2(1, 0);
          final ray =
              Ray2(origin: Vector2(15, 5), direction: direction.normalized());
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
          final ray =
              Ray2(origin: Vector2(5, 5), direction: direction.normalized());
          final segment = LineSegment(Vector2(10, 0), Vector2.all(10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going west',
        () {
          final direction = Vector2(-1, 0);
          final ray =
              Ray2(origin: Vector2(5, 5), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(0, 10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going south',
        () {
          final direction = Vector2(0, 1);
          final ray =
              Ray2(origin: Vector2(5, 5), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 10), Vector2(10, 10));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Correct intersection point length on ray going north',
        () {
          final direction = Vector2(0, -1);
          final ray =
              Ray2(origin: Vector2(5, 5), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), 5);
        },
      );

      test(
        'Origin as intersection point when ray originates on segment',
        () {
          final direction = Vector2(0, -1);
          final ray =
              Ray2(origin: Vector2(5, 0), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), 0);
        },
      );

      test(
        'No intersection when ray is parallel and originates on segment',
        () {
          final direction = Vector2(1, 0);
          final ray =
              Ray2(origin: Vector2(5, 0), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), null);
        },
      );

      test(
        'No intersection point when ray is parallel to the segment',
        () {
          final direction = Vector2(1, 0);
          final ray =
              Ray2(origin: Vector2(-5, 0), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), null);
        },
      );

      test(
        'No intersection point when ray is parallel without intersection',
        () {
          final direction = Vector2(1, 0);
          final ray =
              Ray2(origin: Vector2(5, 5), direction: direction.normalized());
          final segment = LineSegment(Vector2(0, 0), Vector2(10, 0));
          expect(ray.lineSegmentIntersection(segment), null);
        },
      );
    });
  });
}
