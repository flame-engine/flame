import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PositionComponent, () {
    const component = PositionComponent(
      name: 'Player',
      position: ComponentPosition(x: 1, y: 2),
      anchor: ComponentAnchor.center,
      angle: ComponentAngle(radians: 1.5),
      size: ComponentSize(width: 10, height: 20),
      children: [RectangleComponent(name: 'rectangle1')],
    );

    test('supports value equality', () {
      expect(
        const PositionComponent(name: 'Player'),
        equals(const PositionComponent(name: 'Player')),
      );
      expect(component, isNot(equals(const PositionComponent(name: 'Player'))));
      expect(
        const PositionComponent(name: 'Player'),
        isNot(equals(const RectangleComponent(name: 'Player'))),
      );
    });

    test('is a position component with a position and a size', () {
      expect(component.type, equals(ComponentType.position));
      expect(component, isA<PositionedComponent>());
      expect(component, isA<AnchoredComponent>());
      expect(component, isA<RotatedComponent>());
      expect(component, isA<SizedComponent>());
      expect(component, isNot(isA<PaintedComponent>()));
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('toJson includes the type, properties and children', () {
      expect(
        component.toJson(),
        equals({
          'name': 'Player',
          'type': 'position',
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
          'size': {'width': 10.0, 'height': 20.0},
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

    test('copyWithSize replaces only the size', () {
      const size = ComponentSize(width: 1, height: 2);
      final copy = component.copyWithSize(size);

      expect(copy.size, equals(size));
      expect(
        copy.toJson()..remove('size'),
        equals(component.toJson()..remove('size')),
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
