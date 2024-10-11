# Keyboard Input

这包括了键盘输入的文档。

对于其他输入文档，也请参考：

- [手势输入](gesture_input.md)：用于鼠标和触摸指针手势
- [其他输入](other_inputs.md)：用于游戏手柄、游戏杆等

## Intro

Flame 的键盘 API 依赖于 [Flutter 的 Focus widget](https://api.flutter.dev/flutter/widgets/Focus-class.html)。

要自定义焦点行为，请参考 [控制焦点](#controlling-focus)。

游戏可以通过两种方式响应按键输入：在游戏级别和组件级别。
对于每种情况，我们都有一个可以添加到 `Game` 或 `Component` 类的混入。


### Receive keyboard events in a game level

To make a `Game` sub class sensitive to key stroke, mix it with `KeyboardEvents`.

After that, it will be possible to override an `onKeyEvent` method.

This method receives two parameters, first the
[`KeyEvent`](https://api.flutter.dev/flutter/services/KeyEvent-class.html)
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
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

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

Similarly to `TapCallbacks` and `DragCallbacks`, `KeyboardHandler` can be mixed into any subclass of
`Component`.

KeyboardHandlers must only be added to games that are mixed with `HasKeyboardHandlerComponents`.

> ⚠️ Note: If `HasKeyboardHandlerComponents` is used, you must remove `KeyboardEvents`
> from the game mixin list to avoid conflicts.

After applying `KeyboardHandler`, it will be possible to override an `onKeyEvent` method.

This method receives two parameters. First the
[`KeyEvent`](https://api.flutter.dev/flutter/services/KeyEvent-class.html)
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
