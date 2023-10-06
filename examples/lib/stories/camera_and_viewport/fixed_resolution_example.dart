import 'dart:ui' hide TextStyle;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';

class FixedResolutionExample extends FlameGame
    with ScrollDetector, ScaleDetector {
  static const description = '''
    This example shows how to create a viewport with a fixed resolution.
    It is useful when you want the visible part of the game to be the same on
    all devices no matter the actual screen size of the device.
    Resize the window or change device orientation to see the difference.
    
    If you tap once you will set the zoom to 2 and if you tap again it goes back
    to 1, so that you can test how it works with a zoom level.
  ''';
  Vector2 viewportResolution;

  FixedResolutionExample({required this.viewportResolution})
      : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
          world: FixedResolutionWorld(),
        );

  @override
  Future<void> onLoad() async {
    final textRenderer = TextPaint(
      style: TextStyle(fontSize: 25, color: BasicPalette.black.color),
    );
    camera.viewport.add(
      TextComponent(
        text: 'Viewport component\n(always same size)',
        position: Vector2.all(10),
        textRenderer: textRenderer,
      ),
    );
    camera.viewfinder.add(
      TextComponent(
        text: 'Viewfinder component\n(scales with fixed resolution)',
        position: viewportResolution - Vector2.all(10),
        textRenderer: textRenderer,
        anchor: Anchor.bottomRight,
      ),
    );
    camera.lens.add(
      TextComponent(
        text: 'Lens component\n(scales with fixed resolution)',
        position: viewportResolution - Vector2.all(10),
        textRenderer: textRenderer,
        anchor: Anchor.bottomRight,
      ),
    );
  }
}

class FixedResolutionWorld extends World with HasGameReference, TapCallbacks {
  @override
  Future<void> onLoad() async {
    final flameSprite = await game.loadSprite('layers/player.png');

    add(Background());
    add(
      SpriteComponent(
        sprite: flameSprite,
        size: Vector2(149, 211),
      )..anchor = Anchor.center,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final currentZoom = game.camera.viewfinder.zoom;
    game.camera.viewfinder.zoom = currentZoom > 1 ? 1 : 2;
  }
}

class Background extends PositionComponent {
  @override
  int priority = -1;

  late Paint white;
  late final Rect hugeRect;

  Background() : super(size: Vector2.all(100000), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    white = BasicPalette.white.paint();
    hugeRect = size.toRect();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(hugeRect, white);
  }
}
