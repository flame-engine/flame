import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(PaletteColor, () {
    test('copyWith replaces the given fields', () {
      const color = PaletteColor(name: 'primary', color: 0xFF000000);

      expect(
        color.copyWith(name: 'accent'),
        equals(const PaletteColor(name: 'accent', color: 0xFF000000)),
      );
      expect(
        color.copyWith(color: 0xFFFFFFFF),
        equals(const PaletteColor(name: 'primary', color: 0xFFFFFFFF)),
      );
    });
  });

  group(Palette, () {
    const palette = Palette(
      colors: [
        PaletteColor(name: 'primary', color: 0xFFFF0000),
        PaletteColor(name: 'dark_grey', color: 0xFF333333),
      ],
    );

    test('round-trips through JSON', () {
      expect(Palette.fromJson(palette.toJson()), equals(palette));
    });

    test('falls back to an empty palette for invalid JSON', () {
      expect(Palette.fromJson(null), equals(const Palette()));
      expect(Palette.fromJson(const {'colors': 'red'}), const Palette());
    });

    test('skips invalid entries and taken names', () {
      expect(
        Palette.fromJson(const {
          'colors': [
            {'name': 'primary', 'color': 1},
            {'name': 'primary', 'color': 2},
            {'name': 'class', 'color': 3},
            {'name': 'accent', 'color': 'red'},
            'accent',
            {'name': 'accent', 'color': 4},
          ],
        }),
        equals(
          const Palette(
            colors: [
              PaletteColor(name: 'primary', color: 1),
              PaletteColor(name: 'accent', color: 4),
            ],
          ),
        ),
      );
    });

    test('colorOf returns the color with the given name', () {
      expect(palette.colorOf('dark_grey'), equals(0xFF333333));
      expect(palette.colorOf('missing'), isNull);
      expect(palette.colorOf(null), isNull);
      expect(palette.contains('primary'), isTrue);
      expect(palette.contains('missing'), isFalse);
    });

    group('validateColorName', () {
      test('accepts unique identifiers', () {
        expect(palette.validateColorName(2, 'accent'), isNull);
        // A color keeps its own name.
        expect(palette.validateColorName(0, 'primary'), isNull);
      });

      test('rejects invalid names and keywords', () {
        expect(
          palette.validateColorName(2, '1st'),
          equals(PaletteColorNameError.invalid),
        );
        expect(
          palette.validateColorName(2, ''),
          equals(PaletteColorNameError.invalid),
        );
        expect(
          palette.validateColorName(2, 'class'),
          equals(PaletteColorNameError.invalid),
        );
        expect(
          palette.validateColorName(2, '_'),
          equals(PaletteColorNameError.invalid),
        );
      });

      test('rejects names with the same member as another color', () {
        expect(
          palette.validateColorName(2, 'darkGrey'),
          equals(PaletteColorNameError.duplicate),
        );
        expect(
          palette.validateColorName(1, 'primary'),
          equals(PaletteColorNameError.duplicate),
        );
      });
    });

    test('isValid checks every name', () {
      expect(palette.isValid, isTrue);
      expect(
        const Palette(
          colors: [
            PaletteColor(name: 'a', color: 0),
            PaletteColor(name: 'a', color: 0),
          ],
        ).isValid,
        isFalse,
      );
    });

    test('uniqueColorName returns the first free name', () {
      expect(const Palette().uniqueColorName(), equals('color1'));
      expect(
        const Palette(colors: [PaletteColor(name: 'color1', color: 0)])
            .uniqueColorName(),
        equals('color2'),
      );
    });

    test('copyWith replaces the colors', () {
      expect(palette.copyWith(colors: const []), equals(const Palette()));
      expect(palette.copyWith(), equals(palette));
    });
  });
}
