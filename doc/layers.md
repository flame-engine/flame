# Layers

Layers are an useful feature that lets you group renderization by context, as well as allow you yo pre-render things. That enables, for example, the renderization in memory of parts of your game that don't change much, like a background, and by doing that, freeing resources for more dynamic content that needs to be rendered every loop cycle.

There are two types of layers on Flame: `DynamicLayer` (for things that are moving or changing) and `PreRenderedLayer` (for things that are static).

## DynamicLayer

Dynamic layers are layers that are rendered every time that they are draw on the canvas. As the name suggests, it is meant for dynamic content and is most useful to group renderizations that are of the same context.

Usage example:
```dart
class GameLayer extends DynamicLayer {
  final MyGame game;

  GameLayer(this.game);

  @override
  void drawLayer() {
    game.playerSprite.renderRect(
      canvas,
      game.playerRect,
    );
    game.enemySprite.renderRect(
      canvas,
      game.enemyRect,
    );
  }
}

class MyGame extends Game {
  // Other methods ommited...

  @override
  void render(Canvas canvas) {
    gameLayer.render(canvas); // x and y can be provided as optional position arguments
  }
}
```

## PreRenderedLayer

Pre-rendered layers are layers that are rendered only once, cached in memory and then just replicated on the game canvas afterwards. They are most useful to cache content that don't change during the game, like a background for example.

Usage example:
```dart
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite);

  @override
  void drawLayer() {
    sprite.renderRect(
      canvas,
      const Rect.fromLTWH(50, 200, 300, 150),
    );
  }
}

class MyGame extends Game {
  // Other methods ommited...

  @override
  void render(Canvas canvas) {
    backgroundLayer.render(canvas); // x and y can be provided as optional position arguments
  }
}
```

## Layer Processors

Flame also provides a way to add processors on your layer, which are ways to add effects on the entire layer. At the moment, out of the box, only the `ShadowProcessor` is available, this processor renders a cool back drop shadow on your layer.

To add processors to your layer, just add them to the layer `preProcessors` or `postProcessors` list. For example:

```dart
// Works the same for both DynamicLayer and PreRenderedLayer
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() { /* ommited */ }
```

Custom processors can be creted by extending the `LayerProcessor` class.

You can check an working example of layers [here](/doc/examples/layers).
