import 'package:flame/src/anchor.dart';
import 'package:test/test.dart';

void main() {
  group('Anchor', () {
    test('can parse to and from string', () async {
      expect(Anchor.center.toString(), 'center');
      expect(Anchor.valueOf('topRight'), Anchor.topRight);

      expect(Anchor.values.length, 9);

      for (final value in Anchor.values) {
        final thereAndBack = Anchor.valueOf(value.toString());
        expect(thereAndBack, value);
      }
    });
  });
}
