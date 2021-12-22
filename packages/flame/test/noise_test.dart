
import 'package:flame/algos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('noise', () {
    test('noise1', () {
      expect(noise1(0.0), 0);
      expect(noise1(0.1), closeTo(0.008500608, 1e-15));
      expect(noise1(0.2), closeTo(-0.025555968, 1e-15));
      expect(noise1(0.3), closeTo(-0.103027008, 1e-15));
      expect(noise1(0.4), closeTo(-0.199322112, 1e-15));
      expect(noise1(0.5), closeTo(-0.282, 1e-15));
      expect(noise1(0.6), closeTo(-0.323492352, 1e-15));
      expect(noise1(0.7), closeTo(-0.308954688, 1e-15));
      expect(noise1(0.8), closeTo(-0.239244288, 1e-15));
      expect(noise1(0.9), closeTo(-0.129025152, 1e-15));
      expect(noise1(1.0), 0);
      expect(noise1(123.456), closeTo(-0.10695837618123649, 1e-15));
    });

    test('noise2', () {
      expect(noise2(0.0, 0.0), 0);
      expect(noise2(0.0, 1.0), 0);
      expect(noise2(1.0, 0.0), 0);
      expect(noise2(1.0, 1.0), 0);
      expect(noise2(0.1, 0.2), closeTo(0.22425885011712002, 1e-15));
      expect(noise2(0.3, 0.7), closeTo(0.05054124767328006, 1e-15));
      expect(noise2(0.5, 0.99), closeTo(-0.37771127928062087, 1e-15));
      expect(noise2(0.5, 1.0), closeTo(-0.38025, 1e-15));
      expect(noise2(0.5, 1.01), closeTo(-0.382776285026421, 1e-15));
    });

    test('snoise1', () {
      expect(snoise1(0.0), 0);
      expect(snoise1(0.1), closeTo(0.0219623445, 1e-15));
      expect(snoise1(0.2), closeTo(0.018952704, 1e-15));
      expect(snoise1(0.3), closeTo(-0.0314424915, 1e-15));
      expect(snoise1(0.4), closeTo(-0.126373632, 1e-15));
      expect(snoise1(0.5), closeTo(-0.2373046875, 1e-15));
      expect(snoise1(0.6), closeTo(-0.323344128, 1e-15));
      expect(snoise1(0.7), closeTo(-0.3481794435, 1e-15));
      expect(snoise1(0.8), closeTo(-0.293912064, 1e-15));
      expect(snoise1(0.9), closeTo(-0.1678110795, 1e-15));
      expect(snoise1(1.0), 0);
    });

    test('snoise2', () {
      expect(snoise2(0.0, 0.0), 0);
      expect(snoise2(0.0, 1.0), closeTo(-0.7638278795831105, 1e-15));
      expect(snoise2(1.0, 0.0), closeTo(0.1980059241694732, 1e-15));
      expect(snoise2(1.0, 1.0), closeTo(-0.23754742901192183, 1e-15));
      expect(snoise2(0.1, 0.2), closeTo(0.6413558398759025, 1e-15));
      expect(snoise2(0.3, 0.7), closeTo(-0.5167222814846651, 1e-15));
      expect(snoise2(0.5, 0.99), closeTo(0.4600493227780755, 1e-15));
      expect(snoise2(0.5, 1.0), closeTo(0.47805197158363855, 1e-15));
      expect(snoise2(0.5, 1.01), closeTo(0.4959741685171804, 1e-15));
    });
  });
}
