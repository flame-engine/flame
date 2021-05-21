import 'package:flame/extensions.dart';
import 'package:flame/src/anchor.dart';
import 'package:test/test.dart';

void main() {
  group('Anchor', () {
    test('can parse to and from string', () {
      expect(Anchor.center.toString(), 'center');
      expect(Anchor.valueOf('topRight'), Anchor.topRight);

      expect(Anchor.values.length, 9);

      for (final value in Anchor.values) {
        final thereAndBack = Anchor.valueOf(value.toString());
        expect(thereAndBack, value);
      }
    });

    test('can parse custom anchor', () {
      expect(const Anchor(0.2, 0.2).toString(), 'Anchor(0.2, 0.2)');
      expect(Anchor.valueOf('Anchor(0.2, 0.2)'), const Anchor(0.2, 0.2));
    });

    test('fail to parse invalid anchor', () {
      expect(
        () => Anchor.valueOf('foobar'),
        throwsA(isA<AssertionError>()),
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
