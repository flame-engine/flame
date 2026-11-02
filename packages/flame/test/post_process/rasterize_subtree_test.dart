import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('rasterizeSubtree', () {
    const red = Color(0xFFFF0000);
    const blue = Color(0xFF0000FF);

    for (final pixelRatio in [1.0, 1.5, 2.0, 3.0]) {
      test('fills the whole image at pixel ratio $pixelRatio', () async {
        final size = Vector2(40, 20);
        final postProcess = _CapturingPostProcess(pixelRatio: pixelRatio);

        postProcess.render(
          Canvas(PictureRecorder()),
          size,
          (canvas) {
            // Red on the left half, blue on the right half.
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.x / 2, size.y),
              Paint()..color = red,
            );
            canvas.drawRect(
              Rect.fromLTWH(size.x / 2, 0, size.x / 2, size.y),
              Paint()..color = blue,
            );
          },
          (_) {},
        );

        final image = postProcess.image!;
        expect(image.width, (size.x * pixelRatio).ceil());
        expect(image.height, (size.y * pixelRatio).ceil());

        final pixels = await _Pixels.of(image);
        expect(pixels.at(0, 0), red);
        expect(pixels.at(image.width ~/ 4, image.height ~/ 2), red);
        expect(pixels.at(image.width * 3 ~/ 4, image.height ~/ 2), blue);
        expect(pixels.at(image.width - 1, image.height - 1), blue);
      });
    }
  });

  group('PostProcessComponent with rasterizeSubtree', () {
    const goldenFile = '../_goldens/post_process_rasterize_subtree.png';
    final goldenSize = Vector2(200, 100);
    final cardPosition = Vector2(-30, -20);

    testGolden(
      'renders the subtree without a post process',
      (game, tester) async {
        game.world.add(_TestCard()..position = cardPosition);
      },
      goldenFile: goldenFile,
      size: goldenSize,
    );

    for (final pixelRatio in [1.0, 2.0, 3.0]) {
      testGolden(
        'renders the rasterized subtree at its full size at pixel ratio '
        '$pixelRatio',
        (game, tester) async {
          game.world.add(
            PostProcessComponent(
              postProcess: _DrawImagePostProcess(pixelRatio: pixelRatio),
              position: cardPosition,
              size: _TestCard.cardSize,
              children: [_TestCard()],
            ),
          );
        },
        goldenFile: goldenFile,
        size: goldenSize,
      );
    }
  });
}

class _CapturingPostProcess({super.pixelRatio}) extends PostProcess {
  Image? image;

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    image = rasterizeSubtree();
  }
}

/// Draws the rasterized subtree stretched over the size of the post process,
/// which should look exactly like rendering the subtree directly.
class _DrawImagePostProcess({super.pixelRatio}) extends PostProcess {
  final _paint = Paint()..filterQuality = FilterQuality.none;

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    final image = rasterizeSubtree();
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size.toSize(),
      _paint,
    );
  }
}

/// A card made only of pixel aligned rectangles, so that downscaling a
/// rasterized copy of it with nearest sampling gives back the same pixels.
class _TestCard() extends PositionComponent {
  this : super(size: cardSize);

  static Vector2 get cardSize => Vector2(60, 40);

  static final _fill = Paint()..color = const Color(0xFF1E4D8C);
  static final _border = Paint()..color = const Color(0xFFE53935);
  static final _center = Paint()..color = const Color(0xFFFDD835);
  static final _corner = Paint()..color = const Color(0xFF43A047);

  @override
  void render(Canvas canvas) {
    canvas
      ..drawRect(const Rect.fromLTWH(0, 0, 60, 40), _fill)
      ..drawRect(const Rect.fromLTWH(0, 0, 60, 4), _border)
      ..drawRect(const Rect.fromLTWH(0, 36, 60, 4), _border)
      ..drawRect(const Rect.fromLTWH(0, 0, 4, 40), _border)
      ..drawRect(const Rect.fromLTWH(56, 0, 4, 40), _border)
      ..drawRect(const Rect.fromLTWH(20, 14, 20, 12), _center)
      ..drawRect(const Rect.fromLTWH(0, 0, 10, 10), _corner)
      ..drawRect(const Rect.fromLTWH(50, 30, 10, 10), _corner);
  }
}

class _Pixels(final ByteData _bytes, final int _width) {
  static Future<_Pixels> of(Image image) async {
    final data = await image.toByteData();
    return _Pixels(data!, image.width);
  }

  Color at(int x, int y) {
    final offset = (y * _width + x) * 4;
    return Color.fromARGB(
      _bytes.getUint8(offset + 3),
      _bytes.getUint8(offset),
      _bytes.getUint8(offset + 1),
      _bytes.getUint8(offset + 2),
    );
  }
}
