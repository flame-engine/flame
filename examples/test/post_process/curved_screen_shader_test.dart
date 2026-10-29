import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for https://github.com/flame-engine/flame/issues/3766, using
/// the shader and image from the reporter's reproduction.
///
/// The Flame goldens should look like the pure Flutter reference golden. Before
/// the fix, the image passed to the shader by `rasterizeSubtree` only had the
/// subtree in its top left corner, so the screen was shrunk by the pixel ratio.
void main() {
  const shaderAsset = 'shaders/curved_screen.frag';
  const imageAsset = 'assets/images/curved_screen.png';
  const screenWidth = 200.0;
  final goldenSize = Vector2(240, 220);
  final backgroundColor = BasicPalette.brown.color;

  group('curved screen shader from issue #3766', () {
    testWidgets('renders in pure Flutter', (tester) async {
      const key = ValueKey('reference');
      await tester.runAsync(() async {
        final data = await rootBundle.load(imageAsset);
        final codec = await instantiateImageCodec(data.buffer.asUint8List());
        final image = (await codec.getNextFrame()).image;
        final program = await FragmentProgram.fromAsset(shaderAsset);

        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: goldenSize.x,
                height: goldenSize.y,
                child: ColoredBox(
                  color: backgroundColor,
                  child: Center(
                    child: CustomPaint(
                      painter: _CurvedScreenPainter(
                        program.fragmentShader(),
                        image,
                      ),
                      size: Size(
                        screenWidth,
                        screenWidth * image.height / image.width,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });

      await expectLater(
        find.byKey(key),
        matchesGoldenFile('../_goldens/curved_screen_flutter.png'),
      );
    });

    for (final pixelRatio in [1, 2, 3]) {
      testGolden(
        'renders in a PostProcessComponent at pixel ratio $pixelRatio',
        (game, tester) async {
          final image = await game.images.load(imageAsset);
          final program = await FragmentProgram.fromAsset(shaderAsset);
          final screen = SpriteComponent.fromImage(
            image,
            size: Vector2(
              screenWidth,
              screenWidth * image.height / image.width,
            ),
          );

          await game.world.ensureAdd(
            PostProcessComponent(
              postProcess: _CurvedScreenPostProcess(
                program.fragmentShader(),
                pixelRatio: pixelRatio.toDouble(),
              ),
              anchor: Anchor.center,
              size: screen.size,
              children: [screen],
            ),
          );
        },
        goldenFile:
            '../_goldens/curved_screen_flame_pixel_ratio_$pixelRatio.png',
        size: goldenSize,
        backgroundColor: backgroundColor,
      );
    }
  });
}

/// The post process from the reporter's reproduction.
class _CurvedScreenPostProcess(
  final FragmentShader _shader, {
  super.pixelRatio,
}) extends PostProcess {
  late final _paint = Paint()..shader = _shader;

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final subtree = rasterizeSubtree();
    _shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setImageSampler(0, subtree);
    canvas.drawRect(Offset.zero & size.toSize(), _paint);
  }
}

/// The custom painter from the reporter's reproduction.
class _CurvedScreenPainter(
  final FragmentShader _shader,
  final ui.Image _image,
) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setImageSampler(0, _image);
    canvas.drawRect(Offset.zero & size, Paint()..shader = _shader);
  }

  @override
  bool shouldRepaint(_CurvedScreenPainter oldDelegate) => false;
}
