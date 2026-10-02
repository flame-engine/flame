import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('failsAssert', () {
    test('without message', () {
      expect(
        () {
          assert(2 + 2 == 5);
        },
        failsAssert(),
      );
    });

    test('with message', () {
      expect(
        () {
          assert(2 + 2 == 5, 'Basic arithmetic error');
        },
        failsAssert('Basic arithmetic error'),
      );
    });
  });
}
