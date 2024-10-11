# Layers and Snapshots

层和快照共享一些共同特性，包括预渲染和缓存对象以提升性能。然而，它们也有各自独特的功能，使它们更适合不同的使用场景。

`Snapshot` 是一个可以添加到任何 `PositionComponent` 的混入（mixin）。使用它来：

- 混入到现有的游戏对象中（这些对象是 `PositionComponents`）。
- 缓存渲染复杂的游戏对象，例如精灵（sprites）。
- 多次绘制同一对象而不必每次都进行渲染。
- 捕捉图像快照并保存为截图（例如用于截屏）。

`Layer` 是一个类。使用或扩展该类可用于：

- 以逻辑层次结构组织你的游戏（如 UI、前景、主场景、背景）。
- 将对象分组以形成复杂场景，然后进行缓存（例如背景层）。
- 处理器支持。层允许用户定义的处理器在渲染前后运行。


## Layers

层允许你根据上下文对渲染进行分组，并支持预渲染内容。这使得你可以在内存中渲染那些变化不大的游戏部分，例如背景。通过这样做，你可以释放处理能力，用于那些每个游戏帧都需要渲染的动态内容。

在 Flame 中有两种类型的层：

- `DynamicLayer`：用于处理移动或变化的内容。
- `PreRenderedLayer`：用于处理静态内容。


### DynamicLayer

动态层是指每次在画布上绘制时都会被渲染的层。顾名思义，它适用于动态内容，最适合用于将具有相同上下文的对象进行渲染分组。

使用示例：

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

预渲染层只渲染一次，并缓存在内存中，之后仅在游戏画布上进行复制。它们非常适合缓存游戏中不发生变化的内容，例如背景。

使用示例：

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

Flame 还提供了一种在层上添加处理器的方法，它可以为整个层添加效果。目前，Flame 内置的处理器中只有 `ShadowProcessor` 可用，该处理器可以在层上渲染投影效果。

要向层中添加处理器，只需将它们添加到层的 `preProcessors` 或 `postProcessors` 列表中，如下所示：

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

可以通过扩展 `LayerProcessor` 类来创建自定义处理器。

请参阅[层的工作示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/layers_example.dart)。


## Snapshots

快照是层的另一种替代方案。`Snapshot` 混入（mixin）可以应用于任何 `PositionComponent`。

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

将启用快照的组件的 `renderSnapshot` 设置为 `true`（默认值）时，其行为类似于 `PreRenderedLayer`。组件只渲染一次，并缓存在内存中，之后仅在游戏画布上进行复制。这对于缓存游戏中不发生变化的内容（例如背景）非常有用。

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

启用快照的组件将生成其整个树（包括其子组件）的快照。如果任何子组件发生变化（例如，它们的位置发生变化或它们正在执行动画），请调用 `takeSnapshot` 来更新缓存的快照。如果子组件变化非常频繁，最好不要使用 `Snapshot`，因为这将无法带来性能提升。

渲染快照的组件仍然可以进行变换，而不会带来任何性能消耗。一旦快照被捕捉，组件仍然可以进行缩放、移动和旋转。然而，如果组件的内容（即渲染的内容）发生了变化，则必须通过调用 `takeSnapshot` 来重新生成快照。


### Taking a snapshot

启用快照的组件可以在任何时候生成快照，即使 `renderSnapshot` 被设置为 false。这对于截屏或其他需要静态快照的场景（无论是游戏的全部还是部分）都非常有用。

快照总是在没有任何变换的情况下生成的——即生成快照时，启用快照的组件处于位置 (0,0)，且没有缩放或旋转效果。

快照会以 `Picture` 的形式保存，但可以使用 `snapshotToImage` 将其转换为 `Image`。

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

有时，你的快照 `Image` 可能会出现被裁剪或位置不符合预期的情况。

这是因为 `Picture` 的内容可以相对于原点放置在任何位置，但当它被转换为 `Image` 时，图像总是从 `0,0` 开始。这意味着任何具有负坐标位置的内容都会被裁剪掉。

解决这个问题的最佳方法是确保你的 `Snapshot` 组件始终相对于游戏处于位置 `0,0`，并且从不移动它。这样通常可以确保图像包含你预期的内容。

然而，这并不总是可行。如果需要在将快照转换为图像之前移动（或旋转、缩放等）快照，可以向 `snapshotToImage` 传递一个变换矩阵，如下所示：

```dart
// Call something like this to take an image snapshot at any time.
void takeSnapshot() {
  // Prepare a matrix to move the snapshot by 200,50.
  final matrix = Matrix4.identity()..translate(200.0,50.0);

  root.takeSnapshot();
  final image = root.snapshotToImage(200, 200, transform: matrix);
}
```
