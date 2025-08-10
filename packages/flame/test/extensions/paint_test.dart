import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('PaintExtension', () {
    testRandom('calling darken changes the color of the paint', (Random r) {
      final baseColor = ColorExtension.random(rng: r);
      final paint = Paint()..color = baseColor;

      final darkenAmount = r.nextDouble();
      final darkenBaseColor = baseColor.darken(darkenAmount);

      paint.darken(darkenAmount);

      expectColor(
        paint.color,
        darkenBaseColor,
        reason: "Paint's color does not match darken color",
      );
    });

    testRandom('calling brighten changes the color of the paint', (Random r) {
      final baseColor = ColorExtension.random(rng: r);
      final paint = Paint()..color = baseColor;

      final brightenAmount = r.nextDouble();
      final brightenBaseColor = baseColor.brighten(brightenAmount);

      paint.brighten(brightenAmount);

      expectColor(
        paint.color,
        brightenBaseColor,
        reason: "Paint's color does not match brighten color",
      );
    });

    testRandom(
      'using fromRGBHexString returns a new Paint with the right Color',
      (Random r) {
        // As documentation says
        // valid inputs are : ccc, CCC, #ccc, #CCC, #c1c1c1, #C1C1C1, c1c1c1,
        // C1C1C1
        final color = ColorExtension.random();
        final sixHexColor =
            (color.r * 255).toInt().toRadixString(16).padLeft(2, '0') +
            (color.g * 255).toInt().toRadixString(16).padLeft(2, '0') +
            (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');

        // C1C1C1
        final sixUpperCaseColor = sixHexColor.toUpperCase();
        // c1c1c1
        final sixLowerCaseColor = sixHexColor.toLowerCase();
        // #C1C1C1
        final hashtagSixUpperCaseColor = '#$sixUpperCaseColor';
        // #c1c1c1
        final hashtagSixLowerCaseColor = '#$sixLowerCaseColor';

        expectColor(
          PaintExtension.fromRGBHexString(hashtagSixUpperCaseColor).color,
          color,
          reason: 'C1C1C1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(sixLowerCaseColor).color,
          color,
          reason: 'c1c1c1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(hashtagSixUpperCaseColor).color,
          color,
          reason: '#C1C1C1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(hashtagSixLowerCaseColor).color,
          color,
          reason: '#c1c1c1 does not generates the good paint',
        );

        // Let's generate a new color from only 3 digits
        final threeHexColor =
            (color.r ~/ 255).toRadixString(16).padLeft(1, '0')[0] +
            (color.g ~/ 255).toRadixString(16).padLeft(1, '0')[0] +
            (color.b ~/ 255).toRadixString(16).padLeft(1, '0')[0];
        final threeDigitsColor = ColorExtension.fromRGBHexString(threeHexColor);

        // CCC
        final threeUpperCaseColor = threeHexColor.toUpperCase();
        // ccc
        final threeLowerCaseColor = threeHexColor.toLowerCase();
        // #CCC
        final hashtagThreeUpperCaseColor = '#$threeUpperCaseColor';
        // #ccc
        final hashtagThreeLowerCaseColor = '#$threeLowerCaseColor';

        expectColor(
          PaintExtension.fromRGBHexString(threeUpperCaseColor).color,
          threeDigitsColor,
          reason: 'CCC does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(threeLowerCaseColor).color,
          threeDigitsColor,
          reason: 'ccc does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(hashtagThreeUpperCaseColor).color,
          threeDigitsColor,
          reason: '#CCC does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromRGBHexString(hashtagThreeLowerCaseColor).color,
          threeDigitsColor,
          reason: '#ccc does not generates the good paint',
        );
      },
    );

    testRandom(
      'using fromARGBHexString returns a new Paint with the right Color',
      (Random r) {
        // used as an example hex color code on the tests below
        // cSpell:ignore fccc

        // As documentation says
        // valid inputs are : fccc, FCCC, #fccc, #FCCC, #ffc1c1c1, #FFC1C1C1,
        // ffc1c1c1, FFC1C1C1
        var color = ColorExtension.random(rng: r);
        final sixHexColor =
            (color.a * 255).toInt().toRadixString(16).padLeft(2, '0') +
            (color.r * 255).toInt().toRadixString(16).padLeft(2, '0') +
            (color.g * 255).toInt().toRadixString(16).padLeft(2, '0') +
            (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');

        // FFC1C1C1
        final sixUpperCaseColor = sixHexColor.toUpperCase();
        // ffc1c1c1
        final sixLowerCaseColor = sixHexColor.toLowerCase();
        // #FFC1C1C1
        final hashtagSixUpperCaseColor = '#$sixUpperCaseColor';
        // #ffc1c1c1
        final hashtagSixLowerCaseColor = '#$sixLowerCaseColor';

        expectColor(
          PaintExtension.fromARGBHexString(hashtagSixUpperCaseColor).color,
          color,
          reason: 'FFC1C1C1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromARGBHexString(sixLowerCaseColor).color,
          color,
          reason: 'ffc1c1c1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromARGBHexString(hashtagSixUpperCaseColor).color,
          color,
          reason: '#FFC1C1C1 does not generates the good paint',
        );
        expectColor(
          PaintExtension.fromARGBHexString(hashtagSixLowerCaseColor).color,
          color,
          reason: '#ffc1c1c1 does not generates the good paint',
        );

        // Let's generate a new color from only 3 digits
        final threeHexColor =
            (color.a ~/ 255).toRadixString(16).padLeft(1, '0')[0] +
            (color.r ~/ 255).toRadixString(16).padLeft(1, '0')[0] +
            (color.g ~/ 255).toRadixString(16).padLeft(1, '0')[0] +
            (color.b ~/ 255).toRadixString(16).padLeft(1, '0')[0];
        color = ColorExtension.fromARGBHexString(threeHexColor);

        // FCCC
        final threeUpperCaseColor = threeHexColor.toUpperCase();
        // fccc
        final threeLowerCaseColor = threeHexColor.toLowerCase();
        // #FCCC
        final hashtagThreeUpperCaseColor = '#$threeUpperCaseColor';
        // #fccc
        final hashtagThreeLowerCaseColor = '#$threeLowerCaseColor';

        expect(
          PaintExtension.fromARGBHexString(threeUpperCaseColor).color,
          color,
          reason: 'FCCC does not generates the good paint',
        );
        expect(
          PaintExtension.fromARGBHexString(threeLowerCaseColor).color,
          color,
          reason: 'fccc does not generates the good paint',
        );
        expect(
          PaintExtension.fromARGBHexString(hashtagThreeUpperCaseColor).color,
          color,
          reason: '#FCCC does not generates the good paint',
        );
        expect(
          PaintExtension.fromARGBHexString(hashtagThreeLowerCaseColor).color,
          color,
          reason: '#fccc does not generates the good paint',
        );
      },
    );

    testRandom('random returns a new Paint with the right Color', (Random r) {
      // withAlpha is used by Color.fromRGBO witch takes an argument between 0
      // and 1
      final withAlpha = r.nextDouble();
      final base = r.nextInt(256);

      final paint = PaintExtension.random(
        withAlpha: withAlpha,
        base: base,
        rng: r,
      );
      final color = ColorExtension.random(withAlpha: withAlpha, rng: r);

      // As explained in the documentation
      // object with the set alpha as [withAlpha]
      expectColorAlpha(
        paint.color,
        color,
        reason: 'alpha does not have the right value',
      );
    });
  });
}
