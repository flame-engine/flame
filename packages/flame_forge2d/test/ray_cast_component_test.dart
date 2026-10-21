import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _Box(final Vector2 initialPosition) extends BodyComponent {
  @override
  Body createBody() {
    return world.createBody(BodyDef(position: initialPosition))
      ..createShape(Polygon.box(1, 1), ShapeDef(userData: this));
  }
}

void main() {
  group('RayCastComponent', () {
    testWithGame(
      'finds the closest hit when mounted',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        final nearBox = _Box(Vector2(5, 0));
        await game.world.ensureAddAll([nearBox, _Box(Vector2(10, 0))]);
        final ray = RayCastComponent(translation: Vector2(20, 0));
        await game.world.ensureAdd(ray);

        expect(ray.hit, isNotNull);
        expect(ray.hit!.shape.userData, nearBox);
        expect(ray.endPoint, closeToVector(Vector2(4, 0), 0.01));
      },
    );

    testWithGame(
      'finds the farthest hit in farthest mode',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        final nearBox = _Box(Vector2(5, 0));
        final farBox = _Box(Vector2(10, 0));
        await game.world.ensureAddAll([farBox, nearBox]);
        final ray = RayCastComponent(
          translation: Vector2(20, 0),
          mode: RayCastMode.farthest,
        );
        await game.world.ensureAdd(ray);

        expect(ray.hit!.shape.userData, farBox);
        expect(
          ray.hits.map((hit) => hit.shape.userData),
          [nearBox, farBox],
        );
        expect(ray.endPoint, closeToVector(Vector2(9, 0), 0.01));
      },
    );

    testWithGame(
      'finds all hits and ends at the end of the ray in all mode',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        final nearBox = _Box(Vector2(5, 0));
        final farBox = _Box(Vector2(10, 0));
        await game.world.ensureAddAll([farBox, nearBox]);
        final ray = RayCastComponent(
          translation: Vector2(20, 0),
          mode: RayCastMode.all,
        );
        await game.world.ensureAdd(ray);

        expect(ray.hit!.shape.userData, nearBox);
        expect(
          ray.hits.map((hit) => hit.shape.userData),
          [nearBox, farBox],
        );
        expect(ray.endPoint, Vector2(20, 0));
      },
    );

    testWithGame(
      'only keeps the closest hit in closest mode',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        final nearBox = _Box(Vector2(5, 0));
        await game.world.ensureAddAll([nearBox, _Box(Vector2(10, 0))]);
        final ray = RayCastComponent(translation: Vector2(20, 0));
        await game.world.ensureAdd(ray);

        expect(ray.hits.map((hit) => hit.shape.userData), [nearBox]);
      },
    );

    testWithGame(
      'clears the previous hits when the mode changes and nothing is hit',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        await game.world.ensureAdd(_Box(Vector2(5, 0)));
        final ray = RayCastComponent(
          translation: Vector2(20, 0),
          mode: RayCastMode.all,
        );
        await game.world.ensureAdd(ray);
        expect(ray.hits, hasLength(1));

        ray
          ..mode = RayCastMode.farthest
          ..translation.setValues(0, 20);
        game.update(0);

        expect(ray.hit, isNull);
        expect(ray.hits, isEmpty);
        expect(ray.endPoint, Vector2(0, 20));
      },
    );

    testWithGame(
      'ends at the end of the ray when nothing is hit',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        await game.world.ensureAdd(_Box(Vector2(0, 10)));
        final ray = RayCastComponent(
          origin: Vector2(1, 1),
          translation: Vector2(3, 0),
        );
        await game.world.ensureAdd(ray);

        expect(ray.hit, isNull);
        expect(ray.endPoint, Vector2(4, 1));
      },
    );

    testWithGame(
      'recasts the ray on update after the origin and translation change',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        final box = _Box(Vector2(0, 10));
        await game.world.ensureAdd(box);
        final ray = RayCastComponent(translation: Vector2(20, 0));
        await game.world.ensureAdd(ray);
        expect(ray.hit, isNull);

        ray.origin.setValues(0, 5);
        ray.translation.setValues(0, 20);
        game.update(0);

        expect(ray.hit!.shape.userData, box);
        expect(ray.endPoint, closeToVector(Vector2(0, 9), 0.01));
      },
    );

    testWithGame(
      'does not hit shapes that the filter excludes',
      () => Forge2DGame(gravity: Vector2.zero()),
      (game) async {
        await game.world.ensureAdd(_Box(Vector2(5, 0)));
        final ray = RayCastComponent(
          translation: Vector2(20, 0),
          filter: QueryFilter(maskBits: 0),
        );
        await game.world.ensureAdd(ray);

        expect(ray.hit, isNull);
        expect(ray.endPoint, Vector2(20, 0));
      },
    );

    test('does not keep a reference to the given vectors', () {
      final origin = Vector2(1, 2);
      final translation = Vector2(3, 4);
      final ray = RayCastComponent(origin: origin, translation: translation);
      origin.setZero();
      translation.setZero();

      expect(ray.origin, Vector2(1, 2));
      expect(ray.translation, Vector2(3, 4));
    });

    test('uses a stroke paint with the default stroke width', () {
      final ray = RayCastComponent(
        paint: Paint()..color = const Color(0xFF00FF00),
      );
      expect(ray.paint.style, PaintingStyle.stroke);
      expect(
        ray.paint.strokeWidth,
        closeTo(RayCastComponent.defaultStrokeWidth, 1e-6),
      );
      expect(ray.paint.color, const Color(0xFF00FF00));
    });
  });
}
