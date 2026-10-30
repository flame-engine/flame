import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(CircleComponent, () {
    const component = CircleComponent(
      name: 'Player',
      position: ComponentPosition(x: 1, y: 2),
      anchor: ComponentAnchor.center,
      angle: ComponentAngle(radians: 1.5),
      radius: ComponentRadius(radius: 10),
      paint: ComponentPaint(color: 0xFF00FF00, style: PaintStyle.stroke),
      children: [RectangleComponent(name: 'rectangle1')],
    );

    test('supports value equality', () {
      expect(
        const CircleComponent(name: 'Player'),
        equals(const CircleComponent(name: 'Player')),
      );
      expect(component, isNot(equals(const CircleComponent(name: 'Player'))));
    });

    test('is a circle with a position, a radius and a paint', () {
      expect(component.type, equals(ComponentType.circle));
      expect(component, isA<PositionedComponent>());
      expect(component, isA<AnchoredComponent>());
      expect(component, isA<RotatedComponent>());
      expect(component, isA<RadiusComponent>());
      expect(component, isNot(isA<SizedComponent>()));
      expect(component, isA<PaintedComponent>());
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('toJson includes the type, properties and children', () {
      expect(
        component.toJson(),
        equals({
          'name': 'Player',
          'type': 'circle',
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
          'radius': {'radius': 10.0},
          'paint': {'color': 0xFF00FF00, 'style': 'stroke'},
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

    test('copyWithRadius replaces only the radius', () {
      const radius = ComponentRadius(radius: 3);
      final copy = component.copyWithRadius(radius);

      expect(copy.radius, equals(radius));
      expect(
        copy.toJson()..remove('radius'),
        equals(component.toJson()..remove('radius')),
      );
    });

    test('copyWithPaint replaces only the paint', () {
      const paint = ComponentPaint(color: 0xFF0000FF);
      final copy = component.copyWithPaint(paint);

      expect(copy.paint, equals(paint));
      expect(
        copy.toJson()..remove('paint'),
        equals(component.toJson()..remove('paint')),
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
