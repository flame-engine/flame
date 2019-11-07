# Input

Inside `package:flame/gestures.dart` you can find a whole set of `mixin` which can be included on your game class instance to be able to receive touch input events. Bellow you can see the full list of these `mixin`s and its methods:

```dart
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
```

Many of these detectors can conflict with each other, for example, you can't register both Vertical and Horizontal drags, so not all of then can be used together.

All of these methods are basically a mirror from the callbacks available on the [GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html), you can also read more about Flutter's gestures [here](https://api.flutter.dev/flutter/gestures/gestures-library.html).

## Example

```dart
class MyGame extends Game with TapDetector {
  // Other methods ommited

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

Flame also offers a simple helper to make it easier to handle tap events on `PositionComponent`, by using the mixin `Tapable` your components can override the following methods, enabling easy to use tap events on your Component.

```dart
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
```

Minimal component example:

```dart
import 'package:flame/components/component.dart';
import 'package:flame/components/events/gestures.dart';

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
```
