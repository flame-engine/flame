import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

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

  FixedResolutionExample()
      : super(
          camera: CameraComponent.withFixedResolution(width: 600, height: 1024),
          world: FixedResolutionWorld(),
        );

  @override
  Future<void> onLoad() async {
    final textRenderer = TextPaint(
      style: TextStyle(fontSize: 25, color: BasicPalette.black.color),
    );
    camera.viewport.add(
      TextButton(
        text: 'Viewport\ncomponent',
        position: Vector2.all(10),
        textRenderer: textRenderer,
      ),
    );
    camera.viewfinder.add(
      TextButton(
        text: 'Viewfinder\ncomponent',
        textRenderer: textRenderer,
        position: Vector2(0, 200),
        anchor: Anchor.center,
      ),
    );
    camera.viewport.add(
      TextButton(
        text: 'Viewport\ncomponent',
        position: camera.viewport.virtualSize - Vector2.all(10),
        textRenderer: textRenderer,
        anchor: Anchor.bottomRight,
      ),
    );
  }
}

class FixedResolutionWorld extends World
    with HasGameReference, TapCallbacks, DoubleTapCallbacks {
  final red = BasicPalette.red.paint();

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
    add(
      CircleComponent(
        radius: 2,
        position: event.localPosition,
        paint: red,
      ),
    );
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
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

class TextButton extends ButtonComponent {
  TextButton({
    required String text,
    required super.position,
    super.anchor,
    TextRenderer? textRenderer,
  }) : super(
          button: RectangleComponent(
            size: Vector2(200, 100),
            paint: Paint()
              ..color = Colors.orange
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
          ),
          buttonDown: RectangleComponent(
            size: Vector2(200, 100),
            paint: Paint()..color = BasicPalette.orange.color.withOpacity(0.5),
          ),
          children: [
            TextComponent(
              text: text,
              textRenderer: textRenderer,
              position: Vector2(100, 50),
              anchor: Anchor.center,
            ),
          ],
        );
}
