import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '_resources/load_image.dart';

void main() {
  group('Sprite', () {
    testGolden(
      'Render with anchor',
      (game) async {
        game.add(MyComponent()..position = Vector2.all(25));
      },
      goldenFile: '_goldens/sprite_test_1.png',
    );
  });
}

class MyComponent extends PositionComponent {
  MyComponent() : super(size: Vector2(200, 400));
  late final Sprite sprite;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('flame.png'));
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = const Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Expected: sprite is rendered in the center of the rect
    sprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }
}
