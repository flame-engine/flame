import 'dart:io';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flame_svg/svg.dart' as flame_svg;
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _SvgPainter extends CustomPainter {
  final flame_svg.Svg svg;

  _SvgPainter(this.svg);

  @override
  void paint(Canvas canvas, Size size) {
    svg.render(canvas, Vector2(size.width, size.height));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

Future<flame_svg.Svg> _parseSvgFromTestFile(String path) async {
  final svgString = File(path).readAsStringSync();
  final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
  return flame_svg.Svg(pictureInfo);
}

void main() {
  group('Svg', () {
    late flame_svg.Svg svgInstance;

    setUp(() async {
      svgInstance = await _parseSvgFromTestFile('test/_resources/android.svg');
    });

    test('multiple calls to dispose should not throw error', () async {
      svgInstance.render(Canvas(PictureRecorder()), Vector2.all(100));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      svgInstance.dispose();
      svgInstance.dispose();
    });

    test('load from svg string', () async {
      final svg = await flame_svg.Svg.loadFromString(
        File('test/_resources/android.svg').readAsStringSync(),
      );
      expect(svg, isNotNull);
    });

    testWidgets(
      'render sharply',
      (tester) async {
        addTearDown(() {
          tester.view.devicePixelRatio = 1;
        });

        final flameSvg = await _parseSvgFromTestFile(
          'test/_resources/hand.svg',
        );
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
                      painter: _SvgPainter(flameSvg),
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

    testGolden(
      'Svg.withCameraZoom',
      (game) async {
        final world = World()
          ..add(
            SvgComponent(
              anchor: Anchor.center,
              size: Vector2(50, 50),
              svg: await _parseSvgFromTestFile(
                'test/_resources/hand.svg',
              ),
            ),
          );

        final camera = CameraComponent();
        camera.viewfinder.zoom = 2;
        camera.viewfinder.position = Vector2(0, 0);

        game.camera = camera;
        game.world = world;
      },
      goldenFile: './_goldens/render_sharply_with_viewfinder_zoom.png',
      size: Vector2(100, 100),
      backgroundColor: Colors.white,
    );
  });
}
