# Overlays

由于 Flame 游戏可以被封装在一个小部件中，因此很容易将其与你的树中的其他 Flutter 小部件一起使用。然而，如果你想轻松地在 Flame 游戏顶部显示小部件，比如消息、菜单屏幕或类似的东西，你可以使用 Widgets Overlay API 来使事情变得更简单。

`Game.overlays` 允许任何 Flutter 小部件显示在游戏实例的顶部。这使得创建暂停菜单或库存屏幕等变得非常容易。

你可以通过 `game.overlays.add` 和 `game.overlays.remove` 方法使用这个特性，这两个方法分别通过一个 `String` 参数标识要显示或隐藏的覆盖层。之后，你可以通过提供一个 `overlayBuilderMap`，在 `GameWidget` 声明中将每个覆盖层映射到它们对应的小部件。

```dart
  // Inside your game:
  final pauseOverlayIdentifier = 'PauseMenu';

  // Marks 'PauseMenu' to be rendered.
  overlays.add(pauseOverlayIdentifier);
  // Marks 'PauseMenu' to not be rendered.
  overlays.remove(pauseOverlayIdentifier);
```

```dart
// On the widget declaration
final game = MyGame();

Widget build(BuildContext context) {
  return GameWidget(
    game: game,
    overlayBuilderMap: {
      'PauseMenu': (BuildContext context, MyGame game) {
        return Text('A pause menu');
      },
    },
  );
}
```

覆盖层的渲染顺序由 `overlayBuilderMap` 中的键的顺序决定。

查看 [覆盖层特性的示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/system/overlays_example.dart)。
