# Layers and Snapshots

Layers and snapshots share some common features, including the ability to pre-render and cache
objects for improved performance. However, they also have unique features which make them better
suited for different use-cases.

`Snapshot` is a mixin that can be added to any `PositionComponent`. Use this for:

- Mixing in to existing game objects (that are `PositionComponents`).
- Caching game objects, such as sprites, that are complex to render.
- Drawing the same object many times without rendering it each time.
- Capturing an image snapshot to save as a screenshot (for example).

`Layer` is a class. Use or extend this class for:

- Structuring your game with logical layers (e.g. UI, foreground, main, background).
- Grouping objects to form a complex scene, and then caching it (e.g. a background layer).
- Processor support. Layers allow user-defined processors to run pre- and post- render.


## Layers

Layers allow you to group rendering by context, as well as allow you to pre-render things. This
enables, for example, rendering parts of your game that don't change much in memory, like a
background. By doing this, you'll free processing power for more dynamic content that needs to be
rendered every game tick.

There are two types of layers on Flame:

- `DynamicLayer`: For things that are moving or changing.
- `PreRenderedLayer`: For things that are static.


### DynamicLayer

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


### PreRenderedLayer

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


### Layer Processors

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


## Snapshots

Snapshots are an alternative to layers. The `Snapshot` mixin can be applied to any `PositionComponent`.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;

  @override
  Future<void> onLoad() async {
    // Add a snapshot component.
    root = SnapshotComponent();
    add(root);
  }
}
```


### Render as a snapshot

Setting `renderSnapshot` to `true` (the default) on a snapshot-enabled component behaves similarly
to a `PreRenderedLayer`. The component is rendered only once, cached in memory and then just
replicated on the game canvas afterwards. They are useful for caching content that doesn't change
during the game, like a background for example.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;
  late final SpriteComponent background1;
  late final SpriteComponent background2;

  @override
  Future<void> onLoad() async {
    // Add a snapshot component.
    root = SnapshotComponent();
    add(root);

    // Add some children.
    final background1Sprite = Sprite(await images.load('background1.png'));
    background1 = SpriteComponent(sprite: background1Sprite);
    root.add(background1);

    final background2Sprite = Sprite(await images.load('background2.png'));
    background2 = SpriteComponent(sprite: background2Sprite);
    root.add(background2);

    // root will now render once (itself and all its children) and then cache
    // the result. On subsequent render calls, root itself, nor any of its
    // children, will be rendered. The snapshot will be used instead for
    // improved performance.
  }
}
```


#### Regenerating a snapshot

A snapshot-enabled component will generate a snapshot of its entire tree, including its children.
If any of the children change (for example, their position changes, or they are animated), call
`takeSnapshot` to update the cached snapshot. If they are changing very frequently, it's best not
to use a `Snapshot` because there will be no performance benefit.

A component rendering a snapshot can still be transformed without incurring any performance cost.
Once a snapshot has been taken, the component may still be scaled, moved and rotated. However, if
the content of the component changes (what it is rendering) then the snapshot must be regenerated
by calling `takeSnapshot`.


### Taking a snapshot

A snapshot-enabled component can be used to generate a snapshot at any time, even if
`renderSnapshot` is set to false. This is useful for taking screen-grabs or any other purpose when
it may be useful to have a static snapshot of all or part of your game.

A snapshot is always generated with no transform applied - i.e. as if the snapshot-enabled
component is at position (0,0) and has no scale or rotation applied.

A snapshot is saved as a `Picture`, but it can be converted to an `Image` using `snapshotToImage`.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;

  @override
  Future<void> onLoad() async {
    // Add a snapshot component, but don't use its render mode.
    root = SnapshotComponent()..renderSnapshot = false;
    add(root);

    // Other code omitted.
  }

  // Call something like this to take an image snapshot at any time.
  void takeSnapshot() {
    root.takeSnapshot();
    final image = root.snapshotToImage(200, 200);
  }
}
```


### Snapshots that are cropped or off-center

Sometimes your snapshot `Image` may appear cropped, or not in the position that is expected.

This is because the contents of a `Picture` can be positioned anywhere with respect to the origin,
but when it is converted to an `Image`, the image always starts from `0,0`. This means that
anything with a -ve position will be cropped.

The best way to deal with this is to ensure that your `Snapshot` component is always at position
`0,0` with respect to your game and you never move it. This means that the image will usually
contain what you expect it to.

However, this is not always possible. To move (or rotate, or scale etc) the snapshot before
converting it to an image, pass a transformation matrix to `snapshotToImage`.

```dart
// Call something like this to take an image snapshot at any time.
void takeSnapshot() {
  // Prepare a matrix to move the snapshot by 200,50.
  final matrix = Matrix4.identity()..translate(200.0,50.0);

  root.takeSnapshot();
  final image = root.snapshotToImage(200, 200, transform: matrix);
}
```
