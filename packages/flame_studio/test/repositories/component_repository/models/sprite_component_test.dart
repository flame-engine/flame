import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(SpriteComponent, () {
    const sprite = ComponentSprite(
      image: 'assets/images/player.png',
      srcPosition: ComponentPosition(x: 16),
      srcSize: ComponentSize(width: 8, height: 4),
    );
    const component = SpriteComponent(
      name: 'Player',
      position: ComponentPosition(x: 1, y: 2),
      anchor: ComponentAnchor.center,
      angle: ComponentAngle(radians: 1.5),
      size: ComponentSize(width: 10, height: 20),
      sprite: sprite,
      children: [RectangleComponent(name: 'rectangle1')],
    );

    test('is created by Component.create', () {
      expect(
        Component.create('Player', ComponentType.sprite),
        equals(const SpriteComponent(name: 'Player')),
      );
    });

    test('supports value equality', () {
      expect(
        const SpriteComponent(name: 'Player'),
        equals(const SpriteComponent(name: 'Player')),
      );
      expect(component, isNot(equals(const SpriteComponent(name: 'Player'))));
    });

    test('is a sprite with the position component properties', () {
      expect(component.type, equals(ComponentType.sprite));
      expect(component.type.isHitbox, isFalse);
      expect(component, isA<PositionedComponent>());
      expect(component, isA<AnchoredComponent>());
      expect(component, isA<RotatedComponent>());
      expect(component, isA<SizedComponent>());
      expect(component, isA<SpritedComponent>());
      expect(component, isNot(isA<PaintedComponent>()));
    });

    test('round-trips through JSON', () {
      expect(Component.fromJson(component.toJson()), equals(component));
    });

    test('copyWith methods replace one property', () {
      const position = ComponentPosition(x: 9);
      const size = ComponentSize(width: 9);
      const other = ComponentSprite(image: 'other.png');
      expect(component.copyWithPosition(position).position, equals(position));
      expect(
        component.copyWithAnchor(ComponentAnchor.topLeft).anchor,
        equals(ComponentAnchor.topLeft),
      );
      expect(
        component.copyWithAngle(ComponentAngle.zero).angle,
        equals(ComponentAngle.zero),
      );
      expect(component.copyWithSize(size).size, equals(size));
      expect(component.copyWithSprite(other).sprite, equals(other));
      expect(component.copyWithSprite(other).size, equals(component.size));
      expect(component.copyWithName('Other').name, equals('Other'));
      expect(component.copyWithChildren(const []).children, isEmpty);
    });

    test('its tree lists the images it uses', () {
      const tree = PositionComponent(
        name: 'root',
        children: [
          SpriteComponent(name: 'a', sprite: sprite),
          SpriteComponent(name: 'b', sprite: sprite),
          SpriteComponent(name: 'c'),
        ],
      );
      expect(tree.usedImages, equals({'assets/images/player.png'}));
    });
  });
}
