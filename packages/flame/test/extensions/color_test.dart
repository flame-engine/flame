import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Color test', () {
    test('test parse short RGB', () {
      expect(ColorExtension.fromRGBHexString('#234'), const Color(0xFF223344));
      expect(ColorExtension.fromRGBHexString('1f0'), const Color(0xFF11FF00));
      expect(ColorExtension.fromRGBHexString('#ccc'), const Color(0xFFCCCCCC));
      expect(ColorExtension.fromRGBHexString('b1f'), const Color(0xFFBB11FF));
    });

    test('test parse long RGB', () {
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
        ColorExtension.fromRGBHexString('b210af'),
        const Color(0xFFB210AF),
      );
    });
    test('test parse short ARGB', () {
      expect(
        ColorExtension.fromARGBHexString('#fccc'),
        const Color(0xFFCCCCCC),
      );
      expect(
        ColorExtension.fromARGBHexString('fccc'),
        const Color(0xFFCCCCCC),
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
    test('test parse long ARGB', () {
      expect(
        ColorExtension.fromARGBHexString('#ffcc1050'),
        const Color(0xFFCC1050),
      );
      expect(
        ColorExtension.fromARGBHexString('ffccbbaa'),
        const Color(0xFFCCBBAA),
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
  });
}
