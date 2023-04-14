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
      (game) async {
        game.add(MyComponent1());
      },
      goldenFile: '_goldens/nine_tile_box_test_1.png',
    );

    testGolden(
      'Render with specified grid',
      (game) async {
        game.add(MyComponent2());
      },
      goldenFile: '_goldens/nine_tile_box_test_2.png',
    );

    test('default tile sizes calculated correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-1.png'));
      final nineTileBox = NineTileBox(sprite);

      expect(nineTileBox.tileSize, 30);
      expect(nineTileBox.destTileSize, 30);
    });

    test('tile sizes set correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-1.png'));
      final nineTileBox = NineTileBox(sprite, tileSize: 20, destTileSize: 25);

      expect(nineTileBox.tileSize, 20);
      expect(nineTileBox.destTileSize, 25);
    });

    test('grid sizes set correctly', () async {
      final sprite = Sprite(await loadImage('speech-bubble-2.png'));
      final nineTileBox = NineTileBox.withGrid(
        sprite,
        leftColumnWidth: 31,
        rightColumnWidth: 5,
        topRowHeight: 5,
        bottomRowHeight: 21,
      );

      expect(nineTileBox.center.left, 31.0);
      expect(nineTileBox.center.right, 34.0);
      expect(nineTileBox.center.top, 5.0);
      expect(nineTileBox.center.bottom, 18.0);
    });
  });
}

class MyComponent1 extends PositionComponent {
  MyComponent1() : super(size: Vector2(300, 200));
  late final Sprite sprite;
  late final NineTileBox nineTileBox;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('speech-bubble-1.png'));
    nineTileBox = NineTileBox(sprite);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = const Color.fromARGB(255, 57, 113, 158)
    );
    nineTileBox.draw(canvas, Vector2(25, 25), Vector2(250, 150));
  }
}

class MyComponent2 extends PositionComponent {
  MyComponent2() : super(size: Vector2(300, 200));
  late final Sprite sprite;
  late final NineTileBox nineTileBox;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('speech-bubble-2.png'));
    nineTileBox = NineTileBox.withGrid(
      sprite,
      leftColumnWidth: 31,
      rightColumnWidth: 5,
      topRowHeight: 5,
      bottomRowHeight: 21,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = const Color.fromARGB(255, 57, 113, 158)
    );
    nineTileBox.draw(canvas, Vector2(25, 25), Vector2(250, 150));
  }
}
