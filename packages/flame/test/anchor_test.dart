import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Anchor', () {
    test('parses to and from string', () {
      expect(Anchor.center.toString(), 'center');
      expect(Anchor.valueOf('topRight'), Anchor.topRight);

      expect(Anchor.values.length, 9);
      for (final value in Anchor.values) {
        final thereAndBack = Anchor.valueOf(value.toString());
        expect(thereAndBack, value);
      }
    });

    test('parses custom anchor', () {
      const anchor = Anchor(0.2, 0.2);
      expect(anchor.toString(), 'Anchor(0.2, 0.2)');
      expect(Anchor.valueOf('Anchor(0.2, 0.2)'), anchor);
    });

    test('fail to parse invalid anchor', () {
      expect(
        () => Anchor.valueOf('foobar'),
        failsAssert(),
      );
    });

    test('can convert topLeft anchor to another anchor positions', () {
      final position = Vector2(3, 1);
      final size = Vector2(2, 3);
      final center = Anchor.topLeft.toOtherAnchorPosition(
        position,
        Anchor.center,
        size,
      );
      expect(center, position + size / 2);
    });

    test('can convert center anchor to another anchor positions', () {
      final position = Vector2(3, 1);
      final size = Vector2(2, 3);
      final topLeft = Anchor.center.toOtherAnchorPosition(
        position,
        Anchor.topLeft,
        size,
      );
      expect(topLeft, position - size / 2);
    });
  });
}
