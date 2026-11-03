import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentSprite, () {
    const sprite = ComponentSprite(
      image: 'assets/images/player.png',
      srcPosition: ComponentPosition(x: 16, y: 32),
      srcSize: ComponentSize(width: 8, height: 4),
    );

    test('supports value equality', () {
      expect(
        const ComponentSprite(image: 'a.png'),
        equals(const ComponentSprite(image: 'a.png')),
      );
      expect(sprite, isNot(equals(const ComponentSprite())));
    });

    test('round-trips through JSON', () {
      expect(ComponentSprite.fromJson(sprite.toJson()), equals(sprite));
    });

    test('only writes the image when it is set', () {
      expect(const ComponentSprite().toJson(), isNot(contains('image')));
      expect(sprite.toJson()['image'], equals('assets/images/player.png'));
    });

    test('fromJson falls back to the defaults', () {
      expect(ComponentSprite.fromJson(null), equals(const ComponentSprite()));
      expect(
        ComponentSprite.fromJson(const {'image': 1}),
        equals(const ComponentSprite()),
      );
    });
  });
}
