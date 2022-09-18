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
    group('RectangleClipComponent', () {
      testGolden(
        'renders correctly',
        (game) async {
          await game.add(
            ClipComponent.rectangle(
              size: Vector2(100, 100),
              children: [_Rectangle()],
            ),
          );
        },
        goldenFile: '../_goldens/clip_component_rect.png',
      );
    });

    group('CircleClipComponent', () {
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

    group('PolygonClipComponent', () {
      testGolden(
        'renders correctly',
        (game) async {
          await game.add(
            ClipComponent.polygon(
              points: [
                Vector2(1, 0),
                Vector2(1, 1),
                Vector2(0, 1),
                Vector2(1, 0),
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
