import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentData, () {
    group('create', () {
      test('creates a rectangle with default properties', () {
        expect(
          ComponentData.create('Player', ComponentType.rectangle),
          equals(const RectangleComponentData(name: 'Player')),
        );
      });

      test('creates a position component with default properties', () {
        expect(
          ComponentData.create('Player', ComponentType.position),
          equals(const PositionComponentData(name: 'Player')),
        );
      });

      test('creates a circle with default properties', () {
        expect(
          ComponentData.create('Player', ComponentType.circle),
          equals(const CircleComponentData(name: 'Player')),
        );
      });

      test('creates a triangle polygon by default', () {
        expect(
          ComponentData.create('Player', ComponentType.polygon),
          equals(const PolygonComponentData(name: 'Player')),
        );
      });

      test('creates a polygon with the given shape', () {
        expect(
          ComponentData.create(
            'Player',
            ComponentType.polygon,
            polygonShape: PolygonShape.square,
          ),
          equals(
            const PolygonComponentData(
              name: 'Player',
              vertices: ComponentVertices(ComponentVertices.square),
            ),
          ),
        );
      });

      test('creates hitboxes with default properties', () {
        expect(
          ComponentData.create('hitbox', ComponentType.rectangleHitbox),
          equals(const RectangleHitboxData(name: 'hitbox')),
        );
        expect(
          ComponentData.create('hitbox', ComponentType.circleHitbox),
          equals(const CircleHitboxData(name: 'hitbox')),
        );
        expect(
          ComponentData.create(
            'hitbox',
            ComponentType.polygonHitbox,
            polygonShape: PolygonShape.square,
          ),
          equals(
            const PolygonHitboxData(
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
          ComponentData.fromJson(const {
            'name': 'a',
            'type': 'rectangleHitbox',
          }),
          equals(const RectangleHitboxData(name: 'a')),
        );
        expect(
          ComponentData.fromJson(const {'name': 'a', 'type': 'circleHitbox'}),
          equals(const CircleHitboxData(name: 'a')),
        );
        expect(
          ComponentData.fromJson(const {'name': 'a', 'type': 'polygonHitbox'}),
          equals(const PolygonHitboxData(name: 'a')),
        );
      });

      test('reads a polygon', () {
        expect(
          ComponentData.fromJson(const {'name': 'Player', 'type': 'polygon'}),
          equals(const PolygonComponentData(name: 'Player')),
        );
      });

      test('reads a circle', () {
        expect(
          ComponentData.fromJson(const {
            'name': 'Player',
            'type': 'circle',
            'radius': {'radius': 10.0},
          }),
          equals(
            const CircleComponentData(
              name: 'Player',
              radius: ComponentRadius(radius: 10),
            ),
          ),
        );
      });

      test('reads a rectangle', () {
        expect(
          ComponentData.fromJson(const {'name': 'Player', 'type': 'rectangle'}),
          isA<RectangleComponentData>(),
        );
      });

      test('reads a position component with children of other types', () {
        expect(
          ComponentData.fromJson(const {
            'name': 'Player',
            'type': 'position',
            'size': {'width': 10.0, 'height': 20.0},
            'children': [
              {'name': 'rectangle1', 'type': 'rectangle'},
            ],
          }),
          equals(
            const PositionComponentData(
              name: 'Player',
              size: ComponentSize(width: 10, height: 20),
              children: [RectangleComponentData(name: 'rectangle1')],
            ),
          ),
        );
      });

      test('reads the children and skips invalid ones', () {
        expect(
          ComponentData.fromJson(const {
            'name': 'Player',
            'children': [
              {'name': 'rectangle1', 'type': 'rectangle'},
              'invalid',
            ],
          }),
          equals(
            const RectangleComponentData(
              name: 'Player',
              children: [RectangleComponentData(name: 'rectangle1')],
            ),
          ),
        );
      });

      test('reads components without a type as rectangles', () {
        expect(
          ComponentData.fromJson(const {'name': 'Player'}),
          equals(const RectangleComponentData(name: 'Player')),
        );
      });
    });
  });
}
