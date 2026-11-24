import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(ComponentPaint, () {
    test('defaults to a white fill', () {
      const paint = ComponentPaint();

      expect(paint.color, equals(0xFFFFFFFF));
      expect(paint.style, equals(PaintStyle.fill));
    });

    test('round-trips through JSON', () {
      const paint = ComponentPaint(color: 0x80FF0000, style: PaintStyle.stroke);

      expect(ComponentPaint.fromJson(paint.toJson()), equals(paint));
    });

    test('falls back to defaults for missing or invalid values', () {
      expect(ComponentPaint.fromJson(null), equals(const ComponentPaint()));
      expect(
        ComponentPaint.fromJson(const {'color': 'red', 'style': 'dotted'}),
        equals(const ComponentPaint()),
      );
    });

    test('copyWith replaces the given fields', () {
      expect(
        const ComponentPaint().copyWith(color: 0xFF000000),
        equals(const ComponentPaint(color: 0xFF000000)),
      );
      expect(
        const ComponentPaint().copyWith(style: PaintStyle.stroke),
        equals(const ComponentPaint(style: PaintStyle.stroke)),
      );
    });

    test('round-trips a palette color through JSON', () {
      const paint = ComponentPaint(color: 0xFF00FF00, paletteColor: 'primary');

      expect(paint.toJson()['paletteColor'], equals('primary'));
      expect(ComponentPaint.fromJson(paint.toJson()), equals(paint));
    });

    test('omits the palette color from JSON when unset', () {
      expect(const ComponentPaint().toJson(), isNot(contains('paletteColor')));
    });

    test('copyWith keeps the palette color', () {
      expect(
        const ComponentPaint(paletteColor: 'primary')
            .copyWith(style: PaintStyle.stroke)
            .paletteColor,
        equals('primary'),
      );
    });

    test('withColor replaces the palette color by a color', () {
      expect(
        const ComponentPaint(
          paletteColor: 'primary',
          style: PaintStyle.stroke,
        ).withColor(0xFF000000),
        equals(
          const ComponentPaint(color: 0xFF000000, style: PaintStyle.stroke),
        ),
      );
    });

    test('withPaletteColor uses a palette color', () {
      expect(
        const ComponentPaint().withPaletteColor('primary', 0xFF00FF00),
        equals(
          const ComponentPaint(color: 0xFF00FF00, paletteColor: 'primary'),
        ),
      );
    });

    test('resolvedColor reads the palette color, or falls back', () {
      const palette = Palette(
        colors: [PaletteColor(name: 'primary', color: 0xFF0000FF)],
      );

      expect(
        const ComponentPaint(
          color: 0xFF00FF00,
          paletteColor: 'primary',
        ).resolvedColor(palette),
        equals(0xFF0000FF),
      );
      expect(
        const ComponentPaint(
          color: 0xFF00FF00,
          paletteColor: 'missing',
        ).resolvedColor(palette),
        equals(0xFF00FF00),
      );
      expect(
        const ComponentPaint(color: 0xFF00FF00).resolvedColor(palette),
        equals(0xFF00FF00),
      );
    });
  });
}
