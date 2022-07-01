import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Rectangle extends RectangleComponent {
  _Rectangle()
      : super(
          size: Vector2(200, 200),
          anchor: Anchor.center,
          paint: Paint()..color = Colors.blue,
        );
}

void main() {
  group('ClipComponent', () {
    group('ClipComponent.rect', () {
      testGolden(
        'renders correctly',
        (game) async {
          await game.add(
            ClipComponent.rect(
              size: Vector2(100, 100),
              children: [_Rectangle()],
            ),
          );
        },
        goldenFile: '../_goldens/clip_component_rect.png',
      );
    });

    group('ClipComponent.circle', () {
      testGolden(
        'renders correctly',
        (game) async {
          await game.add(
            ClipComponent.circle(
              size: Vector2(100, 100),
              children: [_Rectangle()],
            ),
          );
        },
        goldenFile: '../_goldens/clip_component_circle.png',
      );
    });

    group('ClipComponent.circle', () {
      testGolden(
        'renders correctly',
        (game) async {
          await game.add(
            ClipComponent.polygon(
              points: [
                Vector2(50, 0),
                Vector2(50, 50),
                Vector2(0, 50),
                Vector2(50, 0),
              ],
              size: Vector2(100, 100),
              children: [_Rectangle()],
            ),
          );
        },
        goldenFile: '../_goldens/clip_component_polygon.png',
      );
    });
  });
}
