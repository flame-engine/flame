import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('RandomExtension', () {
    test('nextBoolean returns true with odds > 0.5', () {
      final r = _MockRandom();

      when(r.nextDouble).thenReturn(0.1);
      expect(r.nextBoolean(odds: 0.6), isTrue);

      when(r.nextDouble).thenReturn(0.7);
      expect(r.nextBoolean(odds: 0.6), isFalse);

      when(r.nextDouble).thenReturn(0.5);
      expect(r.nextBoolean(), isFalse);

      expect(() => r.nextBoolean(odds: -0.1), throwsArgumentError);
      expect(() => r.nextBoolean(odds: 1.1), throwsArgumentError);
    });

    test('nextDoubleBetween returns a value in the range', () {
      final r = _MockRandom();

      when(r.nextDouble).thenReturn(0.5);
      expect(r.nextDoubleBetween(1, 3), 2.0);

      when(r.nextDouble).thenReturn(0.0);
      expect(r.nextDoubleBetween(1, 3), 1.0);

      when(r.nextDouble).thenReturn(1.0);
      expect(r.nextDoubleBetween(1, 3), 3.0);
    });

    test('nextIntBetween returns a value in the range', () {
      final r = _MockRandom();

      when(() => r.nextInt(any())).thenReturn(1);
      expect(r.nextIntBetween(1, 3), 2);

      when(() => r.nextInt(any())).thenReturn(0);
      expect(r.nextIntBetween(0, 1), 0);

      when(() => r.nextInt(any())).thenReturn(2);
      expect(r.nextIntBetween(1, 4), 3);

      expect(() => r.nextIntBetween(3, 3), throwsArgumentError);
      expect(() => r.nextIntBetween(3, 2), throwsArgumentError);
    });

    test('nextColor returns a color with RGB values between 0 and 255', () {
      final r = _MockRandom();

      var result = 100;
      when(() => r.nextInt(any())).thenAnswer((_) => result++);
      expect(r.nextColor(), const Color.fromARGB(255, 100, 101, 102));

      when(() => r.nextInt(any())).thenReturn(0);
      expect(r.nextColor(), const Color.fromARGB(255, 0, 0, 0));

      when(() => r.nextInt(any())).thenReturn(255);
      expect(r.nextColor(), const Color.fromARGB(255, 255, 255, 255));
    });
  });
}

class _MockRandom extends Mock implements Random {}
