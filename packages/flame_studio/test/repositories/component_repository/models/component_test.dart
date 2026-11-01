import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(Component, () {
    group('create', () {
      test('creates a rectangle with default properties', () {
        expect(
          Component.create('Player', ComponentType.rectangle),
          equals(const RectangleComponent(name: 'Player')),
        );
      });

      test('creates a position component with default properties', () {
        expect(
          Component.create('Player', ComponentType.position),
          equals(const PositionComponent(name: 'Player')),
        );
      });

      test('creates a circle with default properties', () {
        expect(
          Component.create('Player', ComponentType.circle),
          equals(const CircleComponent(name: 'Player')),
        );
      });

      test('creates a triangle polygon by default', () {
        expect(
          Component.create('Player', ComponentType.polygon),
          equals(const PolygonComponent(name: 'Player')),
        );
      });

      test('creates a polygon with the given shape', () {
        expect(
          Component.create(
            'Player',
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
          equals(
            const PolygonComponent(
              name: 'Player',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ),
        );
      });

      test('creates hitboxes with default properties', () {
        expect(
          Component.create('hitbox', ComponentType.rectangleHitbox),
          equals(const RectangleHitboxComponent(name: 'hitbox')),
        );
        expect(
          Component.create('hitbox', ComponentType.circleHitbox),
          equals(const CircleHitboxComponent(name: 'hitbox')),
        );
        expect(
          Component.create(
            'hitbox',
            ComponentType.polygonHitbox,
            polygonShape: PolygonShape.square,
          ),
          equals(
            const PolygonHitboxComponent(
              name: 'hitbox',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ),
        );
      });
    });

    group('fromJson', () {
      test('reads hitboxes', () {
        expect(
          Component.fromJson(const {'name': 'a', 'type': 'rectangleHitbox'}),
          equals(const RectangleHitboxComponent(name: 'a')),
        );
        expect(
          Component.fromJson(const {'name': 'a', 'type': 'circleHitbox'}),
          equals(const CircleHitboxComponent(name: 'a')),
        );
        expect(
          Component.fromJson(const {'name': 'a', 'type': 'polygonHitbox'}),
          equals(const PolygonHitboxComponent(name: 'a')),
        );
      });

      test('reads a polygon', () {
        expect(
          Component.fromJson(const {'name': 'Player', 'type': 'polygon'}),
          equals(const PolygonComponent(name: 'Player')),
        );
      });

      test('reads a circle', () {
        expect(
          Component.fromJson(const {
            'name': 'Player',
            'type': 'circle',
            'radius': {'radius': 10.0},
          }),
          equals(
            const CircleComponent(
              name: 'Player',
              radius: ComponentRadius(radius: 10),
            ),
          ),
        );
      });

      test('reads a rectangle', () {
        expect(
          Component.fromJson(const {'name': 'Player', 'type': 'rectangle'}),
          isA<RectangleComponent>(),
        );
      });

      test('reads a position component with children of other types', () {
        expect(
          Component.fromJson(const {
            'name': 'Player',
            'type': 'position',
            'size': {'width': 10.0, 'height': 20.0},
            'children': [
              {'name': 'rectangle1', 'type': 'rectangle'},
            ],
          }),
          equals(
            const PositionComponent(
              name: 'Player',
              size: ComponentSize(width: 10, height: 20),
              children: [RectangleComponent(name: 'rectangle1')],
            ),
          ),
        );
      });

      test('reads the children and skips invalid ones', () {
        expect(
          Component.fromJson(const {
            'name': 'Player',
            'children': [
              {'name': 'rectangle1', 'type': 'rectangle'},
              'invalid',
            ],
          }),
          equals(
            const RectangleComponent(
              name: 'Player',
              children: [RectangleComponent(name: 'rectangle1')],
            ),
          ),
        );
      });

      test('reads components without a type as rectangles', () {
        expect(
          Component.fromJson(const {'name': 'Player'}),
          equals(const RectangleComponent(name: 'Player')),
        );
      });
    });
  });
}
