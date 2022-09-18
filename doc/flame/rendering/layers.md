# Layers

Layers allow you to group rendering by context, as well as allow you to pre-render things. This
enables, for example, rendering parts of your game that don't change much in memory, like a
background. By doing this, you'll free processing power for more dynamic content that needs to be
rendered every game tick.

There are two types of layers on Flame:

- `DynamicLayer`: For things that are moving or changing.
- `PreRenderedLayer`: For things that are static.


## DynamicLayer

Dynamic layers are layers that are rendered every time that they are drawn on the canvas. As the
name suggests, it is meant for dynamic content and is most useful for grouping rendering of objects
that have the same context.

Usage example:

```dart
class GameLayer extends DynamicLayer {
  final MyGame game;

  GameLayer(this.game);

  @override
  void drawLayer() {
    game.playerSprite.render(
      canvas,
      position: game.playerPosition,
    );
    game.enemySprite.render(
      canvas,
      position: game.enemyPosition,
    );
  }
}

class MyGame extends Game {
  // Other methods omitted...

  @override
  void render(Canvas canvas) {
    gameLayer.render(canvas); // x and y can be provided as optional position arguments
  }
}
```


## PreRenderedLayer

Pre-rendered layers are rendered only once, cached in memory and then just
replicated on the game canvas afterwards. They are useful for caching content that doesn't change
during the game, like a background for example.

Usage example:

```dart
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite);

  @override
  void drawLayer() {
    sprite.render(
      canvas,
      position: Vector2(50, 200),
    );
  }
}

class MyGame extends Game {
  // Other methods omitted...

  @override
  void render(Canvas canvas) {
    // x and y can be provided as optional position arguments.
    backgroundLayer.render(canvas);
  }
}
```


## Layer Processors

Flame also provides a way to add processors on your layer, which are ways to add effects on the
entire layer. At the moment, out of the box, only the `ShadowProcessor` is available, this processor
renders a back drop shadow on your layer.

To add processors to your layer, just add them to the layer `preProcessors` or `postProcessors`
list. For example:

```dart
// Works the same for both DynamicLayer and PreRenderedLayer
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() { /* omitted */ }

  // ...
```

Custom processors can be created by extending the `LayerProcessor` class.

You can check a working example of layers
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/layers_example.dart).
