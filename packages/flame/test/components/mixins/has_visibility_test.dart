import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_resources/load_image.dart';

void main() {
  group('HasVisibility', () {
    testGolden(
      'Render a Component with isVisible set to false',
      (game, tester) async {
        game.add(_MyComponent()..mySprite.isVisible = false);
      },
      size: Vector2(300, 400),
      goldenFile: '../../_goldens/visibility_test_1.png',
    );
  });
}

class _MySpriteComponent extends PositionComponent with HasVisibility {
  late final Sprite sprite;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(await loadImage('flame.png'));
  }

  @override
  void render(Canvas canvas) {
    sprite.render(canvas, anchor: Anchor.center);
  }
}

/// This component contains a [_MySpriteComponent]. It first
/// renders a rectangle, and then the children will render.
/// In this test the visibility of [mySprite] is set to
/// false, so only the rectangle is expected to be rendered.
class _MyComponent extends PositionComponent {
  _MyComponent() : super(size: Vector2(300, 400)) {
    mySprite = _MySpriteComponent()..position = Vector2(150, 200);
    add(mySprite);
  }
  late final _MySpriteComponent mySprite;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTRB(25, 25, size.x - 25, size.y - 25),
      Paint()
        ..color = const Color(0xffffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    super.render(canvas);
  }
}
