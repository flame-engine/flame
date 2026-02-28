# Game Widget

```{dartdoc}
:package: flame
:symbol: GameWidget
:file: src/game/game_widget/game_widget.dart

[ClipRect]: https://api.flutter.dev/flutter/widgets/ClipRect-class.html
[FocusNode]: https://api.flutter.dev/flutter/widgets/FocusNode-class.html
[RepaintBoundary]: https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html
```


## Hit Test Behavior

The `behavior` argument controls how the `GameWidget` participates in Flutter's hit testing. This
determines whether pointer events (taps, drags, etc.) are absorbed by the game or allowed to pass
through to widgets underneath it in the widget tree.

There are three possible values from Flutter's `HitTestBehavior`:

- **`HitTestBehavior.opaque`** (default): The game absorbs all pointer events on its entire surface,
  preventing any widgets behind it from receiving them. This is the classic behavior where the game
  acts as a solid layer.

- **`HitTestBehavior.deferToChild`**: The game only intercepts events at positions where a component
  with event callbacks (e.g. `TapCallbacks`) exists. Events at positions with no interactive
  components pass through to widgets behind the `GameWidget`. This is useful when layering a game on
  top of Flutter UI and you want the underlying widgets to remain interactive in areas the game
  doesn't need to handle.

- **`HitTestBehavior.translucent`**: The game receives events where it has event-handling components,
  but always allows widgets behind it to be hit-tested as well. Both the game and the widgets behind
  it can receive the same event.


### Allowing taps to pass through

A common use case is placing a `GameWidget` on top of other Flutter widgets in a `Stack`. By
default, the game will block all interaction with the widgets underneath. To let taps pass through
to those widgets, set `behavior` to `HitTestBehavior.deferToChild`:

```dart
Widget build(BuildContext context) {
  return Stack(
    children: [
      // Flutter widgets underneath
      Center(
        child: ElevatedButton(
          onPressed: () => print('Button tapped!'),
          child: const Text('Tap me'),
        ),
      ),
      // Game on top, letting taps pass through
      Positioned.fill(
        child: GameWidget(
          game: MyGame(),
          behavior: HitTestBehavior.deferToChild,
        ),
      ),
    ],
  );
}
```

In this setup, tapping an area with no interactive game components will reach the `ElevatedButton`
behind the game. Tapping a game component that uses `TapCallbacks` will be handled by the game
instead.

```{note}
When using `deferToChild` or `translucent`, `FlameGame` determines whether a
position has an interactive component by traversing the component tree via
`componentsAtPoint`. Games that directly extend the low-level `Game` class
report a hit on their entire surface by default; override
`containsEventHandlerAt` to customize this.
```
