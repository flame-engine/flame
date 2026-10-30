import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PolygonHitboxComponent, () {
    const component = PolygonHitboxComponent(
      name: 'Player',
      position: ComponentPosition(x: 1, y: 2),
      anchor: ComponentAnchor.center,
      angle: ComponentAngle(radians: 1.5),
      vertices: ComponentVertices(ComponentVertices.square),
      collision: ComponentCollision(
        type: HitboxCollisionType.passive,
        isSolid: true,
      ),
      children: [RectangleComponent(name: 'rectangle1')],
    );

    test('supports value equality', () {
      expect(
        const PolygonHitboxComponent(name: 'Player'),
        equals(const PolygonHitboxComponent(name: 'Player')),
      );
      expect(
        component,
        isNot(equals(const PolygonHitboxComponent(name: 'Player'))),
      );
    });

    test('is a polygon hitbox with a position, vertices and a collision', () {
      expect(component.type, equals(ComponentType.polygonHitbox));
      expect(component, isA<PositionedComponent>());
      expect(component, isA<AnchoredComponent>());
      expect(component, isA<RotatedComponent>());
      expect(component, isA<VerticesComponent>());
      expect(component, isNot(isA<RadiusComponent>()));
      expect(component, isNot(isA<SizedComponent>()));
      expect(component, isA<HitboxComponent>());
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('toJson includes the type, properties and children', () {
      expect(
        component.toJson(),
        equals({
          'name': 'Player',
          'type': 'polygonHitbox',
          'children': [
            {
              'name': 'rectangle1',
              'type': 'rectangle',
              'children': <Object>[],
              'position': {'x': 0.0, 'y': 0.0},
              'anchor': {'x': 0.0, 'y': 0.0},
              'angle': {'radians': 0.0},
              'size': {'width': 50.0, 'height': 50.0},
              'paint': {'color': 0xFFFFFFFF, 'style': 'fill'},
            },
          ],
          'position': {'x': 1.0, 'y': 2.0},
          'anchor': {'x': 0.5, 'y': 0.5},
          'angle': {'radians': 1.5},
          'vertices': {
            'vertices': [
              {'x': 0.0, 'y': 0.0},
              {'x': 50.0, 'y': 0.0},
              {'x': 50.0, 'y': 50.0},
              {'x': 0.0, 'y': 50.0},
            ],
          },
          'collision': {'type': 'passive', 'isSolid': true},
        }),
      );
    });

    test('copyWithPosition replaces only the position', () {
      const position = ComponentPosition(x: 5, y: 6);
      final copy = component.copyWithPosition(position);

      expect(copy.position, equals(position));
      expect(
        copy.toJson()..remove('position'),
        equals(component.toJson()..remove('position')),
      );
    });

    test('copyWithAnchor replaces only the anchor', () {
      const anchor = ComponentAnchor(x: 0.25, y: 1);
      final copy = component.copyWithAnchor(anchor);

      expect(copy.anchor, equals(anchor));
      expect(
        copy.toJson()..remove('anchor'),
        equals(component.toJson()..remove('anchor')),
      );
    });

    test('is anchored at its top left corner when saved without an '
        'anchor', () {
      final json = component.toJson()..remove('anchor');

      expect(
        (Component.fromJson(json) as AnchoredComponent).anchor,
        equals(ComponentAnchor.topLeft),
      );
    });

    test('copyWithAngle replaces only the angle', () {
      const angle = ComponentAngle(radians: 3);
      final copy = component.copyWithAngle(angle);

      expect(copy.angle, equals(angle));
      expect(
        copy.toJson()..remove('angle'),
        equals(component.toJson()..remove('angle')),
      );
    });

    test('is not rotated when saved without an angle', () {
      final json = component.toJson()..remove('angle');

      expect(
        (Component.fromJson(json) as RotatedComponent).angle,
        equals(ComponentAngle.zero),
      );
    });

    test('copyWithVertices replaces only the vertices', () {
      const vertices = ComponentVertices();
      final copy = component.copyWithVertices(vertices);

      expect(copy.vertices, equals(vertices));
      expect(
        copy.toJson()..remove('vertices'),
        equals(component.toJson()..remove('vertices')),
      );
    });

    test('copyWithCollision replaces only the collision', () {
      const collision = ComponentCollision(isSolid: true);
      final copy = component.copyWithCollision(collision);

      expect(copy.collision, equals(collision));
      expect(
        copy.toJson()..remove('collision'),
        equals(component.toJson()..remove('collision')),
      );
    });

    test('copyWithName replaces only the name', () {
      final copy = component.copyWithName('Enemy');

      expect(copy.name, equals('Enemy'));
      expect(
        copy.toJson()..remove('name'),
        equals(component.toJson()..remove('name')),
      );
    });

    test('copyWithChildren replaces only the children', () {
      final copy = component.copyWithChildren(const []);

      expect(copy.children, isEmpty);
      expect(
        copy.toJson()..remove('children'),
        equals(component.toJson()..remove('children')),
      );
    });
  });
}
