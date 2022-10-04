import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('ColorExtension', () {
    test('parse short RGB', () {
      expect(ColorExtension.fromRGBHexString('#234'), const Color(0xFF223344));
      expect(ColorExtension.fromRGBHexString('1f0'), const Color(0xFF11FF00));
      expect(ColorExtension.fromRGBHexString('#ccc'), const Color(0xFFCCCCCC));
      expect(ColorExtension.fromRGBHexString('b1f'), const Color(0xFFBB11FF));
    });

    test('Parse RGB fails if format is not correct', () {
      var colorHex = ''.padRight(1);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(1);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = ''.padRight(2);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(2);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = ''.padRight(7);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(7);
      expect(
        () => ColorExtension.fromRGBHexString(colorHex),
        throwsA((Object e) => true),
      );
    });

    test('Parse ARGB fails if format is not correct', () {
      var colorHex = ''.padRight(1);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(1);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = ''.padRight(2);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(2);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = ''.padRight(8);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
      colorHex = '#'.padRight(8);
      expect(
        () => ColorExtension.fromARGBHexString(colorHex),
        throwsA((Object e) => true),
      );
    });

    test('parse long RGB', () {
      expect(
        ColorExtension.fromRGBHexString('#121314'),
        const Color(0xFF121314),
      );
      expect(
        ColorExtension.fromRGBHexString('100ff0'),
        const Color(0xFF100FF0),
      );
      expect(
        ColorExtension.fromRGBHexString('#cccccc'),
        const Color(0xFFCCCCCC),
      );
      expect(
        ColorExtension.fromRGBHexString('decade'),
        const Color(0xFFDECADE),
      );
    });

    test('parse short ARGB', () {
      expect(
        ColorExtension.fromARGBHexString('#fccc'),
        const Color(0xFFCCCCCC),
      );
      expect(
        ColorExtension.fromARGBHexString('dead'),
        const Color(0xDDEEAADD),
      );
      expect(
        ColorExtension.fromARGBHexString('#8cc0'),
        const Color(0x88CCCC00),
      );
      expect(
        ColorExtension.fromARGBHexString('0b21'),
        const Color(0x00BB2211),
      );
    });

    test('parse long ARGB', () {
      expect(
        ColorExtension.fromARGBHexString('#ffcc1050'),
        const Color(0xFFCC1050),
      );
      expect(
        ColorExtension.fromARGBHexString('0defaced'),
        const Color(0x0DEFACED),
      );
      expect(
        ColorExtension.fromARGBHexString('#80cccc00'),
        const Color(0x80CCCC00),
      );
      expect(
        ColorExtension.fromARGBHexString('01234567'),
        const Color(0x01234567),
      );
    });

    test('random: errors', () {
      expect(
        () => ColorExtension.random(base: -1),
        failsAssert('The base argument should be in the range 0..256'),
      );
      expect(
        () => ColorExtension.random(base: 257),
        failsAssert('The base argument should be in the range 0..256'),
      );
    });
  });
}
