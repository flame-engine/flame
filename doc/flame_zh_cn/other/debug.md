# 调试功能

## FlameGame 功能

Flame 为 `FlameGame` 类提供了一些调试功能。当 `debugMode` 属性被设置为 `true`（或被覆盖为 `true`）时，这些功能会被启用。启用 `debugMode` 后，每个 `PositionComponent` 将会显示其边界大小，并在屏幕上显示其位置。这样，你可以直观地验证组件的边界和位置。

查看[`FlameGame` 调试功能的工作示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/debug_example.dart)。

## 开发工具扩展

如果你打开 [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview)，你会看到一个名为 "Flame" 的新选项卡。该选项卡将显示当前游戏的相关信息，例如组件树的可视化、控制游戏的播放、暂停和单步调试的功能、选定组件的信息等。

## FPS

Flame 报告的 FPS（帧率）可能会比例如 Flutter DevTools 报告的帧率稍低，这取决于目标平台。你应该以我们报告的 FPS 作为游戏实际帧率的标准，因为这是游戏循环的实际运行帧率。

### FpsComponent

`FpsComponent` 可以添加到组件树中的任意位置，并用于跟踪当前游戏的渲染 FPS。如果你希望将 FPS 显示为游戏中的文本，请使用 `FpsTextComponent`。

### FpsTextComponent

`FpsTextComponent` 本质上是一个包装了 `FpsComponent` 的 [TextComponent]，因为通常你希望在使用 `FpsComponent` 时，在某个地方显示当前 FPS。

[TextComponent]: ../rendering/text_rendering.md#textcomponent

### ChildCounterComponent

`ChildCounterComponent` 是一个组件，它会每秒渲染目标组件 (`target`) 中类型为 `T` 的子组件数量。例如：

以下代码将渲染 `SpriteAnimationComponent` 类型的子组件数量，它们是游戏 `world` 的子组件：

```dart
add(
ChildCounterComponent<SpriteAnimationComponent>(
target: world,
),
);
```

### TimeTrackComponent

此组件允许开发者跟踪代码中某个部分的时间消耗。这对于调试代码中特定部分的性能问题非常有用。

要使用它，只需将其添加到游戏中（由于这是一个调试功能，我们建议只在调试版本/环境中添加该组件）：

```dart
add(TimeTrackComponent());
```

然后在你希望跟踪时间的代码部分中，执行以下操作：

```dart
void update(double dt) {
  TimeTrackComponent.start('MyComponent.update');
  // ...
  TimeTrackComponent.end('MyComponent.update');
}
```

通过上述调用，添加的 `TimeTrackComponent` 将会以微秒为单位显示经过的时间。
