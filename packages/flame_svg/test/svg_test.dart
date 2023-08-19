import 'dart:io';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame_svg/svg.dart' as flame_svg;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class SvgPainter extends CustomPainter {
  final flame_svg.Svg svg;

  SvgPainter(this.svg);

  @override
  void paint(Canvas canvas, Size size) {
    svg.render(canvas, Vector2(size.width, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Future<flame_svg.Svg> parseSvgFromTestFile(String path) async {
  final svgString = File(path).readAsStringSync();
  final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
  return flame_svg.Svg(pictureInfo);
}

void main() {
  group('Svg', () {
    late flame_svg.Svg svgInstance;

    setUp(() async {
      svgInstance = await parseSvgFromTestFile('test/_resources/android.svg');
    });

    test('multiple calls to dispose should not throw error', () async {
      svgInstance.render(Canvas(PictureRecorder()), Vector2.all(100));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      svgInstance.dispose();
      svgInstance.dispose();
    });

    testWidgets(
      'render sharply',
      (tester) async {
        final flameSvg = await parseSvgFromTestFile('test/_resources/hand.svg');
        flameSvg.render(Canvas(PictureRecorder()), Vector2.all(300));
        await tester.binding.setSurfaceSize(const Size(800, 600));
        tester.view.devicePixelRatio = 3;
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SvgPicture.string(
                        File('test/_resources/hand.svg').readAsStringSync(),
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: SvgPainter(flameSvg),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('./_goldens/render_sharply.png'),
        );
      },
    );
  });
}
