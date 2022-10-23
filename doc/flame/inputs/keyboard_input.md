# Keyboard Input

This includes documentation for keyboard inputs.

For other input documents, see also:

- [Gesture Input](gesture_input.md): for mouse and touch pointer gestures
- [Other Inputs](other_inputs.md): For joysticks, game pads, etc.


## Intro

The keyboard API on flame relies on the
[Flutter's Focus widget](https://api.flutter.dev/flutter/widgets/Focus-class.html).

To customize focus behavior, see [Controlling focus](#controlling-focus).

There are two ways a game can react to key strokes; at the game level and at a component level.
For each we have a mixin that can me added to a `Game` or `Component` class.


### Receive keyboard events in a game level

To make a `Game` sub class sensitive to key stroke, mix it with `KeyboardEvents`.

After that, it will be possible to override an `onKeyEvent` method.

This method receives two parameters, first the
[`RawKeyEvent`](https://api.flutter.dev/flutter/services/RawKeyEvent-class.html)
that triggers the callback in the first place. The second is a set of the currently pressed
[`LogicalKeyboardKey`](https://api.flutter.dev/flutter/services/LogicalKeyboardKey-class.html).

The return value is a
[`KeyEventResult`](https://api.flutter.dev/flutter/widgets/KeyEventResult.html).

`KeyEventResult.handled` will tell the framework that the key stroke was resolved inside of Flame
and skip any other keyboard handler widgets apart of `GameWidget`.

`KeyEventResult.ignored` will tell the framework to keep testing this event in any other keyboard
handler widget apart of `GameWidget`. If the event is not resolved by any handler, the framework
will trigger `SystemSoundType.alert`.

`KeyEventResult.skipRemainingHandlers` is very similar to `.ignored`, apart from the fact that will
skip any other handler widget and will straight up play the alert sound.

Minimal example:

```dart
class MyGame extends FlameGame with KeyboardEvents {
  // ...
  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.altLeft) ||
          keysPressed.contains(LogicalKeyboardKey.altRight)) {
        this.shootHarder();
      } else {
        this.shoot();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
```


### Receive keyboard events in a component level

To receive keyboard events directly in components, there is the mixin `KeyboardHandler`.

Similarly to `Tappable` and `Draggable`, `KeyboardHandler` can be mixed into any subclass of
`Component`.

KeyboardHandlers must only be added to games that are mixed with `HasKeyboardHandlerComponents`.

> ⚠️ Note: If `HasKeyboardHandlerComponents` is used, you must remove `KeyboardEvents`
> from the game mixin list to avoid conflicts.

After applying `KeyboardHandler`, it will be possible to override an `onKeyEvent` method.

This method receives two parameters. First the
[`RawKeyEvent`](https://api.flutter.dev/flutter/services/RawKeyEvent-class.html)
that triggered the callback in the first place. The second is a set of the currently pressed
[`LogicalKeyboardKey`](https://api.flutter.dev/flutter/services/LogicalKeyboardKey-class.html)s.

The returned value should be `true` to allow the continuous propagation of the key event among other
components. To not allow any other component to receive the event, return `false`.

Flame also provides a default implementation called `KeyboardListenerComponent` which can be used
to handle keyboard events. Like any other component, it can be added as a child to a `FlameGame`
or another `Component`:

For example, imagine a `PositionComponent` which has methods to move on the X and Y axis,
then the following code could be used to bind those methods to key events:

```dart
add(
  KeyboardListenerComponent(
    keyUp: {
      LogicalKeyboardKey.keyA: (keysPressed) { ... },
      LogicalKeyboardKey.keyD: (keysPressed) { ... },
      LogicalKeyboardKey.keyW: (keysPressed) { ... },
      LogicalKeyboardKey.keyS: (keysPressed) { ... },
    },
    keyDown: {
      LogicalKeyboardKey.keyA: (keysPressed) { ... },
      LogicalKeyboardKey.keyD: (keysPressed) { ... },
      LogicalKeyboardKey.keyW: (keysPressed) { ... },
      LogicalKeyboardKey.keyS: (keysPressed) { ... },
    },
  ),
);
```


### Controlling focus

On the widget level, it is possible to use the
[`FocusNode`](https://api.flutter.dev/flutter/widgets/FocusNode-class.html) API to control whether
the game is focused or not.

`GameWidget` has an optional `focusNode` parameter that allow its focus to be controlled externally.

By default `GameWidget` has its `autofocus` set to true, which means it will get focused once it is
mounted. To override that behavior, set `autofocus` to false.

For a more complete example see
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/keyboard_example.dart).
