import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_resources/load_image.dart';

void main() {
  group('NineTileBox', () {
    testGolden(
      'Render with default grid',
      (game, tester) async {
        game.add(_MyComponent1());
      },
      size: Vector2(300, 200),
      goldenFile: '_goldens/nine_tile_box_test_1.png',
    );

    testGolden(
      'Render with specified grid',
      (game, tester) async {
        game.add(_MyComponent2());
      },
      size: Vector2(300, 200),
      goldenFile: '_goldens/nine_tile_box_test_2.png',
    );

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

class _MyComponent1 extends PositionComponent {
  _MyComponent1() : super(size: Vector2(300, 200));
  late final Sprite sprite;
  late final NineTileBox nineTileBox;
  final bgPaint = Paint()..color = const Color.fromARGB(255, 57, 113, 158);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('speech-bubble-1.png'));
    nineTileBox = NineTileBox(sprite);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      bgPaint,
    );
    nineTileBox.draw(canvas, Vector2(25, 25), Vector2(250, 150));
  }
}

class _MyComponent2 extends PositionComponent {
  _MyComponent2() : super(size: Vector2(300, 200));
  late final Sprite sprite;
  late final NineTileBox nineTileBox;
  final bgPaint = Paint()..color = const Color.fromARGB(255, 57, 113, 158);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('speech-bubble-2.png'));
    nineTileBox = NineTileBox.withGrid(
      sprite,
      leftWidth: 31,
      rightWidth: 5,
      topHeight: 5,
      bottomHeight: 21,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      bgPaint,
    );
    nineTileBox.draw(canvas, Vector2(25, 25), Vector2(250, 150));
  }
}
