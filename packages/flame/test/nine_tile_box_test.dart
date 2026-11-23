import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '_resources/load_image.dart';

void main() {
  group('NineTileBox', () {
    _testGoldenBox(
      'default constructor',
      imagePath: _spriteImage,
      dstSize: Vector2(48, 48),
      createNineTileBoxOverride: NineTileBox.new,
      goldenFilePath: '_goldens/nine_tile_box_default.png',
    );

    _testGoldenBox(
      'withGrid constructor',
      imagePath: _spriteImage,
      dstSize: Vector2(48, 48),
      createNineTileBoxOverride: (sprite) => NineTileBox.withGrid(
        sprite,
        leftWidth: 16,
        rightWidth: 16,
        topHeight: 16,
        bottomHeight: 16,
      ),
      goldenFilePath: '_goldens/nine_tile_box_default.png',
    );

    group('Sprite', () {
      _testGoldenBox(
        'destination size larger than three tiles',
        imagePath: _spriteImage,
        dstSize: Vector2(120, 80),
        goldenFilePath: '_goldens/nine_tile_box_large.png',
      );

      _testGoldenBox(
        'destination size between two and three tiles',
        imagePath: _spriteImage,
        dstSize: Vector2(40, 40),
        goldenFilePath: '_goldens/nine_tile_box_medium.png',
      );

      _testGoldenBox(
        'destination size smaller than two tiles',
        imagePath: _spriteImage,
        dstSize: Vector2(20, 20),
        goldenFilePath: '_goldens/nine_tile_box_small.png',
      );
    });

    group('Spritesheet', () {
      _testGoldenBox(
        'destination size larger than three tiles',
        imagePath: _spritesheetImage,
        srcPosition: Vector2(16, 16),
        srcSize: Vector2(48, 48),
        dstSize: Vector2(120, 80),
        goldenFilePath: '_goldens/nine_tile_box_large.png',
      );

      _testGoldenBox(
        'destination size between two and three tiles',
        imagePath: _spritesheetImage,
        srcPosition: Vector2(16, 16),
        srcSize: Vector2(48, 48),
        dstSize: Vector2(40, 40),
        goldenFilePath: '_goldens/nine_tile_box_medium.png',
      );

      _testGoldenBox(
        'destination size smaller than two tiles',
        imagePath: _spritesheetImage,
        srcPosition: Vector2(16, 16),
        srcSize: Vector2(48, 48),
        dstSize: Vector2(20, 20),
        goldenFilePath: '_goldens/nine_tile_box_small.png',
      );
    });

    test('default tile sizes calculated correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-1.png'));
      final nineTileBox = NineTileBox(sprite);

      expect(nineTileBox.tileSize, equals(30));
      expect(nineTileBox.destTileSize, equals(30));
    });

    test('tile sizes set correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-1.png'));
      final nineTileBox = NineTileBox(sprite, tileSize: 20, destTileSize: 25);

      expect(nineTileBox.tileSize, equals(20));
      expect(nineTileBox.destTileSize, equals(25));
    });

    test('grid sizes set correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-2.png'));
      final nineTileBox = NineTileBox.withGrid(
        sprite,
        leftWidth: 31,
        rightWidth: 5,
        topHeight: 5,
        bottomHeight: 21,
      );

      expect(nineTileBox.center.left, equals(31.0));
      expect(nineTileBox.center.right, equals(34.0));
      expect(nineTileBox.center.top, equals(5.0));
      expect(nineTileBox.center.bottom, equals(18.0));
    });
  });
}

const _spriteImage = 'nine-tile-sprite.png';
const _spritesheetImage = 'nine-tile-spritesheet.png';
final _boxCanvasSize = Vector2(160, 120);

void _testGoldenBox(
  String description, {
  required String imagePath,
  required Vector2 dstSize,
  required String goldenFilePath,
  Vector2? srcPosition,
  Vector2? srcSize,
  NineTileBox Function(Sprite sprite)? createNineTileBoxOverride,
}) {
  testGolden(
    description,
    (game, tester) async {
      game.add(
        _BoxComponent(
          imagePath,
          _boxCanvasSize,
          dstSize,
          createNineTileBoxOverride ??
              (sprite) => NineTileBox(sprite, tileSize: 16),
          srcPosition: srcPosition,
          srcSize: srcSize,
        ),
      );
    },
    size: _boxCanvasSize,
    goldenFile: goldenFilePath,
  );
}

class _BoxComponent(
  final String imagePath,
  final Vector2 canvasSize,
  final Vector2 dstSize,
  final NineTileBox Function(Sprite sprite) createBox, {
  final Vector2? srcPosition,
  final Vector2? srcSize,
}) extends PositionComponent {
  this : super(size: canvasSize);
  late final NineTileBox nineTileBox;
  final bgPaint = Paint()..color = const Color.fromARGB(255, 57, 113, 158);

  @override
  Future<void> onLoad() async {
    final sprite = Sprite(
      await loadImage(imagePath),
      srcPosition: srcPosition,
      srcSize: srcSize,
    );

    nineTileBox = createBox(sprite);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      bgPaint,
    );

    nineTileBox.draw(canvas, (size - dstSize) / 2, dstSize);
  }
}
