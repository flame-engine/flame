import 'package:flame/src/extensions/double.dart';
import 'package:test/test.dart';

void main() {
  group('DoubleExtension', () {
    test('Properly converts infinite values to maxFinite', () {
      const infinity = double.infinity;
      expect(infinity.toFinite(), double.maxFinite);
      const negativeInfinity = -double.infinity;
      expect(negativeInfinity.toFinite(), -double.maxFinite);
    });

    test('Does not convert already finite value', () {
      expect(0.0.toFinite(), 0.0);
      expect(double.maxFinite.toFinite(), double.maxFinite);
      expect((-double.maxFinite).toFinite(), -double.maxFinite);
    });
  });
}
