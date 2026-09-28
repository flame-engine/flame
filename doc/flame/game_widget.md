# Game Widget

The `GameWidget` is the bridge between Flutter and Flame. Since Flame games are not Flutter widgets
by themselves, the `GameWidget` wraps a `Game` instance and places it into the Flutter widget tree,
just like any other [widget](https://docs.flutter.dev/get-started/fundamentals/widgets). This lets
you combine a full-screen game with Flutter UI elements (navigation bars, overlays, dialogs) or
embed a game as only part of your app's layout.

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

- **`HitTestBehavior.deferToChild`**: The game is asked, position by position, whether the event is
  its own, by calling `containsEventHandlerAt`. Events it declines pass through to widgets behind
  the `GameWidget`. This is useful when layering a game on top of Flutter UI and you want the
  underlying widgets to remain interactive in areas the game doesn't need to handle. See
  [Deciding what the game absorbs](#deciding-what-the-game-absorbs) below, since the default answer
  is "everything".

- **`HitTestBehavior.translucent`**: The game absorbs events on its entire surface, and the widgets
  behind it are hit-tested as well, so both can receive the same event.


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

On its own this is not enough: `deferToChild` asks the game which positions are its own, and a game
answers "all of them" unless told otherwise. Add the `DeferHitTestToComponents` mixin so it answers
based on its components:

```dart
class MyGame extends FlameGame with DeferHitTestToComponents {}
```

With both in place, tapping an area with no interactive game components reaches the
`ElevatedButton` behind the game, while tapping a component that uses `TapCallbacks` is handled by
the game.


### Deciding what the game absorbs

`containsEventHandlerAt` answers, for a single position, whether the game wants the event. It is
only consulted under `deferToChild`; `opaque` and `translucent` decide without asking.

By default it returns `true` everywhere, which is why a game is opaque until you opt out. There are
two ways to change that:

- add the `DeferHitTestToComponents` mixin, which walks the components at that point and reports a
  hit if any of them implements `PointerInputCallbacks` (which every positional callbacks mixin
  does);
- or override `containsEventHandlerAt` with your own rule, for instance a fixed rectangle, which
  avoids the per-event tree walk that the mixin costs.

Note that a `FlameGame` which handles pointer events itself, by mixing in something like
`TapCallbacks` directly, is interactive across its whole surface; the mixin has nothing to defer in
that case and asserts.
