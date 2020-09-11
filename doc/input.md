# Input

## Gestures

Inside `package:flame/gestures.dart` you can find a whole set of `mixin`s which can be included on your game class instance to be able to receive touch input events. Below you can see the full list of these `mixin`s and its methods:


## Touch and mouse detectors
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

Mouse only events
```
 - MouseMovementDetector
  - onMouseMove
 - ScrollDetector
  - onScroll
```

Many of these detectors can conflict with each other. For example, you can't register both Vertical and Horizontal drags, so not all of them can be used together.

It is also not possible to mix advanced detectors (`MultiTouch*`) with basic detectors as they will *always win the gesture arena* and the basic detectors will never be triggered. So for example, you can use both `MultiTouchDragDetector` and `MultiTouchDragDetector` together, but if you try to use `MultiTouchTapDetector` and `PanDetector`, no events will be triggered for the later.

Flame's GestureApi is provided byt Flutter's Gestures Widgets, including [GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html), [RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html) and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html), you can also read more about Flutter's gestures [here](https://api.flutter.dev/flutter/gestures/gestures-library.html).

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

## Joystick

Flame provides a component capable of creating a virtual joystick for taking input for your game. It can be configure with a variaty of combinations, like using two sticks, or only one stick and some pressable buttons, and so on.

To use this feature. You need to create a `JoystickComponent`, configure it the way you want, and add it to your game.

To receive the inputs from the joystick component, you need to have a class which implements a `JoystickListener`, and that class needs to be added as an observer of the joystick component previous created. That implementer of the the `JoystickListener` could be any class, but one common practice is for it to be your component that will be controlled by the joystick, like a player component for example.

Check this example to get a better understanding:

```dart
import 'package:flame/components/joystick/joystick_action.dart';
import 'package:flame/components/joystick/joystick_component.dart';
import 'package:flame/components/joystick/joystick_directional.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

class MyGame extends BaseGame with MultiTouchDragDetector {
  final player = Player();
  final joystick = JoystickComponent(
    componentPriority: 0,
    directional: JoystickDirectional(
      spriteBackgroundDirectional: Sprite('directional_background.png'), // optional
      spriteKnobDirectional: Sprite('directional_knob.png'), // optional
      isFixed: true, // optional
      margin: const EdgeInsets.only(left: 100, bottom: 100), // optional
      size: 80, // optional
      color: Colors.blueGrey, // optional
      opacityBackground: 0.5, // optional
      opacityKnob: 0.8, // optional
    ),
    actions: [
      JoystickAction(
        actionId: 1, // required
        sprite: Sprite('action.png'), // optional
        spritePressed: Sprite('action_pressed.png'), // optional
        spriteBackgroundDirection: Sprite('action_direction_background.png'), // optional
        enableDirection: false, // optional
        size: 50, // optional
        sizeFactorBackgroundDirection: 1.5, // optional
        margin: const EdgeInsets.all(50), // optional
        color: Colors.blueGrey, // optional
        align: JoystickActionAlign.BOTTOM_RIGHT, // optional
        opacityBackground: 0.5, // optional
        opacityKnob: 0.8, // optional
      ),
    ],
  );

  MyGame() {
    joystick.addObserver(player);
    add(player);
    add(joystick);
  }

  @override
  void onReceiveDrag(DragEvent drag) {
    joystick.onReceiveDrag(drag);
    super.onReceiveDrag(drag);
  }
}

class Player extends Component implements JoystickListener {

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {}

  @override
  void joystickAction(JoystickActionEvent event) {
    // Do anything when click in action button.
    print('Action: $event');
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    // Do anything when interact with directional.
    print('Directional: $event');
  }

}

```

### JoystickDirectionalEvent

```dart

  JoystickDirectionalEvent({
    JoystickMoveDirectional directional,
    double intensity = 0.0,
    double radAngle = 0.0,
  });

  enum JoystickMoveDirectional {
    MOVE_UP,
    MOVE_UP_LEFT,
    MOVE_UP_RIGHT,
    MOVE_RIGHT,
    MOVE_DOWN,
    MOVE_DOWN_RIGHT,
    MOVE_DOWN_LEFT,
    MOVE_LEFT,
    IDLE
  }

```

### JoystickActionEvent

```dart

  JoystickActionEvent({
      int id,
      double intensity = 0.0,
      double radAngle = 0.0,
      ActionEvent event,
   });

  enum ActionEvent { DOWN, UP, MOVE, CANCEL }

```

You can also check a more complete example [here](/doc/examples/joystick).

