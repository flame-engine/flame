# Input

The `Game` class has a vast number of methods for handling touch controls, to use it, just override the method you want to use, and that method will start receiving events, below there is the whole list of available methods:

```dart
  void onTap() {}
  void onTapCancel() {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
  void onSecondaryTapDown(TapDownDetails details) {}
  void onSecondaryTapUp(TapUpDetails details) {}
  void onSecondaryTapCancel() {}
  void onDoubleTap() {}
  void onLongPress() {}
  void onLongPressStart(LongPressStartDetails details) {}
  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {}
  void onLongPressUp() {}
  void onLongPressEnd(LongPressEndDetails details) {}
  void onVerticalDragDown(DragDownDetails details) {}
  void onVerticalDragStart(DragStartDetails details) {}
  void onVerticalDragUpdate(DragUpdateDetails details) {}
  void onVerticalDragEnd(DragEndDetails details) {}
  void onVerticalDragCancel() {}
  void onHorizontalDragDown(DragDownDetails details) {}
  void onHorizontalDragStart(DragStartDetails details) {}
  void onHorizontalDragUpdate(DragUpdateDetails details) {}
  void onHorizontalDragEnd(DragEndDetails details) {}
  void onHorizontalDragCancel() {}
  void onForcePressStart(ForcePressDetails details) {}
  void onForcePressPeak(ForcePressDetails details) {}
  void onForcePressUpdate(ForcePressDetails details) {}
  void onForcePressEnd(ForcePressDetails details) {}
  void onPanDown(DragDownDetails details) {}
  void onPanStart(DragStartDetails details) {}
  void onPanUpdate(DragUpdateDetails details) {}
  void onPanEnd(DragEndDetails details) {}
  void onPanCancel() {}
  void onScaleStart(ScaleStartDetails details) {}
  void onScaleUpdate(ScaleUpdateDetails details) {}
  void onScaleEnd(ScaleEndDetails details) {}
```

All those methods are basically a mirror from the callbacks available on the [GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html), you can also read more about Flutter's gestures [here](https://api.flutter.dev/flutter/gestures/gestures-library.html).

## Example

```dart
class MyGame extends Game {
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
