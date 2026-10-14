import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_svg/svg_paths.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle() extends Mock implements AssetBundle;

String _svg(List<(String, String)> paths) {
  final buffer = StringBuffer(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">',
  );
  for (final (index, (color, extra)) in paths.indexed) {
    final x = index * 10;
    buffer.write(
      '<path d="M$x 0L${x + 5} 0L${x + 5} 5Z" fill="$color" $extra/>',
    );
  }
  buffer.write('</svg>');
  return buffer.toString();
}

void main() {
  group('SvgPaths', () {
    test('without merge, keeps every path', () {
      final svg = SvgPaths(
        _svg([('#ff0000', ''), ('#ff0000', ''), ('#00ff00', '')]),
        merge: false,
      );
      expect(svg.length, 3);
    });

    test('computes its bounds once', () {
      final svg = SvgPaths(_svg([('#ff0000', ''), ('#00ff00', '')]));
      expect(svg.bounds, const Rect.fromLTRB(0, 0, 15, 5));
      expect(identical(svg.bounds, svg.bounds), isTrue);
    });

    test('has the bounds of the imported paths only', () {
      // The clip is not imported, so it is not part of the bounds.
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<clipPath id="c"><rect width="100" height="100"/></clipPath> '
        '<g clip-path="url(#c)"> '
        '<path d="M10 10L20 10L20 20Z" fill="#ff0000"/> </g> </svg>',
      );
      expect(svg.bounds, const Rect.fromLTRB(10, 10, 20, 20));
    });

    test('has the size of the SVG file', () {
      final svg = SvgPaths(_svg([('#ff0000', '')]));
      expect(svg.size, const Size(100, 100));
    });

    test('merges consecutive paths with the same paint', () {
      final svg = SvgPaths(
        _svg([('#ff0000', ''), ('#ff0000', ''), ('#00ff00', '')]),
      );
      expect(svg.length, 2);
      expect(svg.paintAt(0).fill!.color.toARGB32(), 0xffff0000);
      expect(svg.paintAt(1).fill!.color.toARGB32(), 0xff00ff00);
    });

    test('does not merge paths separated by another paint', () {
      final svg = SvgPaths(
        _svg([('#ff0000', ''), ('#00ff00', ''), ('#ff0000', '')]),
      );
      expect(svg.length, 3);
      expect(svg.paintAt(0).fill!.color.toARGB32(), 0xffff0000);
      expect(svg.paintAt(1).fill!.color.toARGB32(), 0xff00ff00);
      expect(svg.paintAt(2).fill!.color.toARGB32(), 0xffff0000);
    });

    test('does not merge paths with both a fill and a stroke', () {
      final svg = SvgPaths(
        _svg([
          ('#ff0000', 'stroke="#000000" stroke-width="2"'),
          ('#ff0000', 'stroke="#000000" stroke-width="2"'),
        ]),
      );
      expect(svg.length, 2);
    });

    test('keeps the strokes without a width', () {
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<path d="M10 10L90 90" fill="none" stroke="#000000"/> '
        '<path d="M10 90L90 10Z" fill="#ff0000" stroke="#000000"/> </svg>',
      );
      expect(svg.length, 2);
      expect(svg.paintAt(0).isFilled, isFalse);
      expect(svg.paintAt(0).stroke!.strokeWidth, 1);
      expect(svg.paintAt(1).isFilled, isTrue);
      expect(svg.paintAt(1).stroke!.strokeWidth, 1);
    });

    test('keeps the strokes with a negative width', () {
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<path d="M10 10L90 90" fill="none" stroke="#000000" '
        'stroke-width="-1"/> </svg>',
      );
      expect(svg.length, 1);
      expect(svg.paintAt(0).stroke!.strokeWidth, 1);
    });

    test('gives each path its own paint when they share the same data', () {
      // The vector graphics compiler shares the paths with the same data.
      const d = 'M0 0L50 0L50 50Z';
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<path d="$d" fill="#ff0000"/> <path d="$d" fill="#0000ff"/> </svg>',
      );
      expect(svg.length, 2);
      expect(svg.pathAt(0).paint.fill!.color.toARGB32(), 0xffff0000);
      expect(svg.pathAt(1).paint.fill!.color.toARGB32(), 0xff0000ff);
    });

    group('merge with overlapping paths', () {
      String svgOf(List<String> paths, [String style = '']) {
        final elements = [
          for (final d in paths) '<path d="$d" fill="#ff0000" $style/> ',
        ];
        return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
            '${elements.join()}</svg>';
      }

      const a = 'M0 0L50 0L50 50L0 50Z';
      const overlapsA = 'M25 25L75 25L75 75L25 75Z';
      const farFromA = 'M60 60L90 60L90 90L60 90Z';
      const besideA = 'M50 0L90 0L90 50L50 50Z';

      test('merges paths that do not overlap', () {
        expect(SvgPaths(svgOf([a, farFromA])).length, 1);
      });

      test('merges paths that only touch', () {
        expect(SvgPaths(svgOf([a, besideA])).length, 1);
      });

      test('does not merge paths that overlap', () {
        expect(SvgPaths(svgOf([a, overlapsA])).length, 2);
      });

      test('merges the paths after an overlap that do not overlap', () {
        // The second path overlaps the first one, but not the third one.
        const farFromBoth = 'M80 80L95 80L95 95L80 95Z';
        expect(SvgPaths(svgOf([a, overlapsA, farFromBoth])).length, 2);
      });

      test('does not merge strokes that only reach each other', () {
        // The lines are 5 units apart, and their strokes are 4 units wide.
        const lines = ['M10 10L90 10', 'M10 15L90 15'];
        const style = 'fill="none" stroke="#000000" stroke-width="4"';
        expect(SvgPaths(svgOf(lines, style)).length, 2);
        expect(SvgPaths(svgOf(lines, style), merge: false).length, 2);
      });

      test('does not merge strokes whose miter joins reach each other', () {
        // The sharp join at (40, 50) reaches up to 25 times the half width
        // of the stroke with this miter limit, past the vertical line.
        const lines = ['M0 48L40 50L0 52', 'M85 20L85 80'];
        const style = 'fill="none" stroke="#000000" stroke-width="10"';
        expect(SvgPaths(svgOf(lines, style)).length, 1);
        expect(
          SvgPaths(svgOf(lines, '$style stroke-miterlimit="50"')).length,
          2,
        );
      });

      test('skips the paths that paint nothing', () {
        const svg =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
            '<linearGradient id="g"></linearGradient> '
            '<rect width="10" height="10" fill="url(#g)"/> '
            '<rect x="20" width="10" height="10" fill="#ff0000"/> </svg>';
        final paths = SvgPaths(svg, merge: false);
        expect(paths.length, 1);
        expect(paths.bounds, const Rect.fromLTRB(20, 0, 30, 10));
      });

      test('does not merge paths across an unsupported command', () {
        // The clipped path in the middle is separated from the others by the
        // clip command and the restore command.
        const svg =
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
            '<clipPath id="c"><rect width="50" height="50"/></clipPath> '
            '<path d="M0 0L20 0L20 20Z" fill="#ff0000"/> '
            '<g clip-path="url(#c)"> '
            '<path d="M30 30L40 30L40 40Z" fill="#ff0000"/> </g> '
            '<path d="M60 60L70 60L70 70Z" fill="#ff0000"/> </svg>';
        expect(SvgPaths(svg).length, 3);
        expect(SvgPaths(svg.replaceAll('clip-path="url(#c)"', '')).length, 1);
      });

      testWidgets('keeps the overlap of even-odd paths filled', (tester) async {
        final svg = SvgPaths(
          svgOf([a, overlapsA], 'fill-rule="evenodd"'),
        );
        final alpha = (await tester.runAsync(() async {
          final recorder = PictureRecorder();
          svg.render(Canvas(recorder), Vector2.all(100));
          final image = await recorder.endRecording().toImage(100, 100);
          final data = (await image.toByteData())!;
          return data.getUint8((35 * 100 + 35) * 4 + 3);
        }))!;
        expect(alpha, 255);
      });
    });

    group('fromFile', () {
      final svg = _svg([('#ff0000', ''), ('#ff0000', '')]);

      AssetsCache cacheOf(AssetBundle bundle) {
        when(() => bundle.loadString(any())).thenAnswer((_) async => svg);
        return AssetsCache(bundle: bundle);
      }

      test('reads the file via the given cache', () async {
        final bundle = _MockAssetBundle();
        final paths = await SvgPaths.fromFile(
          'assets/svgs/a.svg',
          cache: cacheOf(bundle),
        );
        verify(() => bundle.loadString('assets/svgs/a.svg')).called(1);
        expect(paths.length, 1);
      });

      test('reads the file within the given package', () async {
        final bundle = _MockAssetBundle();
        await SvgPaths.fromFile(
          'assets/svgs/a.svg',
          cache: cacheOf(bundle),
          package: 'my_pkg',
        );
        verify(
          () => bundle.loadString('packages/my_pkg/assets/svgs/a.svg'),
        ).called(1);
      });

      test('reads the file via Flame.assets by default', () async {
        final previous = Flame.assets;
        addTearDown(() => Flame.assets = previous);
        final bundle = _MockAssetBundle();
        Flame.assets = cacheOf(bundle);
        await SvgPaths.fromFile('assets/svgs/a.svg');
        verify(() => bundle.loadString('assets/svgs/a.svg')).called(1);
      });

      test('passes on the merge', () async {
        final paths = await SvgPaths.fromFile(
          'assets/svgs/a.svg',
          cache: cacheOf(_MockAssetBundle()),
          merge: false,
        );
        expect(paths.length, 2);
      });
    });

    group('with an SVG that can not be used', () {
      test('throws if it can not be parsed', () {
        expect(() => SvgPaths('garbage'), throwsA(anything));
        expect(() => SvgPaths(''), throwsA(anything));
      });

      testWidgets('renders nothing if it is empty', (tester) async {
        final svg = SvgPaths(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"/>',
        );
        expect(svg.length, 0);
        final recorder = PictureRecorder();
        expect(
          () =>
              svg.render(Canvas(recorder), Vector2.all(100), area: svg.bounds),
          returnsNormally,
        );
      });
    });

    group('render', () {
      // A red square from (50, 50) to (55, 55), in a 100x100 SVG.
      final svg = SvgPaths(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"> '
        '<path d="M50 50L55 50L55 55L50 55Z" fill="#ff0000"/> </svg>',
      );

      Future<ByteData> render(
        WidgetTester tester, {
        Rect? area,
        void Function(Canvas)? draw,
      }) async {
        return (await tester.runAsync(() async {
          final recorder = PictureRecorder();
          final canvas = Canvas(recorder);
          if (draw != null) {
            draw(canvas);
          } else {
            svg.render(canvas, Vector2.all(20), area: area);
          }
          final image = await recorder.endRecording().toImage(20, 20);
          return await image.toByteData();
        }))!;
      }

      int alphaAt(ByteData data, int x, int y) {
        return data.getUint8((y * 20 + x) * 4 + 3);
      }

      testWidgets('uses the override paint', (tester) async {
        final data = await render(
          tester,
          draw: (canvas) => svg.render(
            canvas,
            Vector2.all(20),
            overridePaint: Paint()..color = const Color(0xff0000ff),
          ),
        );
        // The pixel at (10, 10) is blue instead of red, in RGBA order.
        expect(data.getUint8((10 * 20 + 10) * 4), 0);
        expect(data.getUint8((10 * 20 + 10) * 4 + 2), 255);
      });

      testWidgets('renders at the given position', (tester) async {
        final data = await render(
          tester,
          draw: (canvas) => svg.renderPosition(
            canvas,
            Vector2.all(10),
            Vector2.all(10),
            area: const Rect.fromLTWH(50, 50, 5, 5),
          ),
        );
        expect(alphaAt(data, 15, 15), 255);
        expect(alphaAt(data, 5, 5), 0);
      });

      testWidgets('renders at the given position with the override paint', (
        tester,
      ) async {
        final data = await render(
          tester,
          draw: (canvas) => svg.renderPosition(
            canvas,
            Vector2.all(10),
            Vector2.all(10),
            area: const Rect.fromLTWH(50, 50, 5, 5),
            overridePaint: Paint()..color = const Color(0xff0000ff),
          ),
        );
        // The pixel at (15, 15) is blue instead of red, in RGBA order.
        expect(data.getUint8((15 * 20 + 15) * 4), 0);
        expect(data.getUint8((15 * 20 + 15) * 4 + 2), 255);
      });

      testWidgets('fits the whole SVG by default', (tester) async {
        final data = await render(tester);
        expect(alphaAt(data, 10, 10), 255); // The square at (10, 10).
        expect(alphaAt(data, 2, 2), 0);
      });

      testWidgets('fits the given area', (tester) async {
        final data = await render(
          tester,
          area: const Rect.fromLTWH(50, 50, 5, 5),
        );
        expect(alphaAt(data, 2, 2), 255);
        expect(alphaAt(data, 17, 17), 255);
      });
    });
  });
}
