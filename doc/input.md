# Input

## Gestures

Inside `package:flame/gestures.dart` you can find a whole set of `mixin`s which can be included on your game class instance to be able to receive touch input events. Below you can see the full list of these `mixin`s and its methods:

```
- TapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onTapUp

- SecondaryTapDetector
  - onSecondaryTapDown
  - onSecondaryTapUp
  - onSecondaryTapCancel

- DoubleTapDetector
  - onDoubleTap

- LongPressDetector
  - onLongPress
  - onLongPressStart
  - onLongPressMoveUpdate
  - onLongPressUp
  - onLongPressEnd

- VerticalDragDetector
  - onVerticalDragDown
  - onVerticalDragStart
  - onVerticalDragUpdate
  - onVerticalDragEnd
  - onVerticalDragCancel

- HorizontalDragDetector
  - onHorizontalDragDown
  - onHorizontalDragStart
  - onHorizontalDragUpdate
  - onHorizontalDragEnd
  - onHorizontalDragCancel

- ForcePressDetector
  - onForcePressStart
  - onForcePressPeak
  - onForcePressUpdate
  - onForcePressEnd

- PanDetector
  - onPanDown
  - onPanStart
  - onPanUpdate
  - onPanEnd
  - onPanCancel

- ScaleDetector
  - onScaleStart
  - onScaleUpdate
  - onScaleEnd

 - MultiTouchTapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onTapUp

 - MultiTouchDragDetector
  - onReceiveDrag
```

Many of these detectors can conflict with each other. For example, you can't register both Vertical and Horizontal drags, so not all of them can be used together.

It is also not possible to mix advanced detectors (`MultiTouch*`) with basic detectors as they will *always win the gesture arena* and the basic detectors will never be triggered. So for example, you can use both `MultiTouchDragDetector` and `MultiTouchDragDetector` together, but if you try to use `MultiTouchTapDetector` and `PanDetector`, no events will be triggered for the later.

Flame's GestureApi is provided byt Flutter's Gestures Widgets, including [GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) and [RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html), you can also read more about Flutter's gestures [here](https://api.flutter.dev/flutter/gestures/gestures-library.html).

## Example

```dart
class MyGame extends Game with TapDetector {
  // Other methods omitted

  @override
  void onTapDown(TapDownDetails details) {
    print("Player tap down on ${details.globalPosition.dx} - ${details.globalPosition.dy}");
  }

  @override
  void onTapUp(TapUpDetails details) {
    print("Player tap up on ${details.globalPosition.dx} - ${details.globalPosition.dy}");
  }
}
```
You can also check a more complete example [here](/doc/examples/gestures).

## Tapable components

Flame also offers a simple helper to make it easier to handle tap events on `PositionComponent`. By adding the `HasTapableComponents` mixin to your game, and using the mixin `Tapable` on your components can override the following methods, enabling easy to use tap events on yours components.

```dart
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
```

Minimal component example:

```dart
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';

class TapableComponent extends PositionComponent with Tapable {

  // update and render omitted

  @override
  void onTapUp(TapUpDetails details) {
    print("tap up");
  }

  @override
  void onTapDown(TapDownDetails details) {
    print("tap down");
  }

  @override
  void onTapCancel() {
    print("tap cancel");
  }
}

class MyGame extends BaseGame with HasTapableComponents {
  MyGame() {
    add(TapableComponent());
  }
}
```

## Keyboard

Flame provides a simple way to access Flutter's features regarding accessing Keyboard input events.

To use it, just add the `KeyboardEvents` mixin to your game class.
When doing this you will need to implement the `onKeyEvent` method, this method is called every time a keyboard event happens, and it receives an instance of the Flutter class `RawKeyEvent`.
This event can be used to get information about what occurred, like if it was a key down or key up event, and which key was pressed etc.

Minimal example:

```dart
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/services.dart';

class MyGame extends Game with KeyboardEvents {
  // update and render omitted

  @override
  void onKeyEvent(e) {
    final bool isKeyDown = e is RawKeyDownEvent;
    print(" Key: ${e.data.keyLabel} - isKeyDown: $isKeyDown");
  }
}
```

You can also check a more complete example [here](/doc/examples/keyboard).
