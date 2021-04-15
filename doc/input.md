# Input

## Gestures

Inside `package:flame/gestures.dart` you can find a whole set of `mixin`s which can be included on
your game class instance to be able to receive touch input events. Below you can see the full list
of these `mixin`s and its methods:

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

Many of these detectors can conflict with each other. For example, you can't register both vertical
and horizontal drags, so not all of them can be used together.

It is also not possible to mix advanced detectors (`MultiTouch*`) with basic detectors as they will
*always win the gesture arena* and the basic detectors will never be triggered. So for example, you
can use both `MultiTouchDragDetector` and `MultiTouchDragDetector` together, but if you try to use
`MultiTouchTapDetector` and `PanDetector`, no events will be triggered for the latter.

Flame's GestureApi is provided by Flutter's Gesture Widgets, including
GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html)
and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html), you can
also read more about Flutter's gestures
[here](https://api.flutter.dev/flutter/gestures/gestures-library.html).

## Event coordinate system

On events that have positions, like for example `Tap*` or `Drag`, you will notice that the `eventPosition`
attribute includes 3 fields: `game`, `widget` and `global`. Below you will find a brief explanation
about each one of them.

### global

The position where the event occurred considering the entire screen, same as
`globalPosition` in Flutter's native events.

### widget

The position where the event occurred relative to the `GameWidget` position and size
, same as `localPosition` in Flutter's native events.

### game

The position where the event ocurred relative to the `GameWidget` and with any
transformations that the game applied to the game (e.g. camera). If the game doesn't have any
transformations, this will be equal to the `widget` attribute.

## Example

```dart
class MyGame extends Game with TapDetector {
  // Other methods omitted

  @override
  void onTapDown(TapDownInfo event) {
    print("Player tap down on ${event.eventPosition.game}");
  }

  @override
  void onTapUp(TapUpInfo event) {
    print("Player tap up on ${event.eventPosition.game}");
  }
}
```

You can also check more complete examples
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/controls/).

## Tapable and Draggable components

Any component derived from `BaseComponent` (most components) can add the `Tapable` and/or the
`Draggable` mixins to handle taps and drags on the component.

All overridden methods return a boolean to control if the event should be passed down further along
to components underneath it. So say that you only want your top visible component to receive a tap
and not the ones underneath it, then your `onTapDown`, `onTapUp` and `onTapCancel` implementations
should return `false` and if you want the event to go through more of the components underneath then
you should return `true`.

The same applies if your component has children, then the event is first sent to the leaves in the
children tree and then passed further down until a method returns `false`.

### Tapable components

By adding the `HasTapableComponents` mixin to your game, and using the mixin `Tapable` on your
components, you can override the following methods on your components:

```dart
void onTapCancel() {}
void onTapDown(TapDownInfo event) {}
void onTapUp(TapUpInfo event) {}
```

Minimal component example:

```dart
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/tapable.dart';

class TapableComponent extends PositionComponent with Tapable {

  // update and render omitted

  @override
  void onTapUp(TapUpInfo event) {
    print("tap up");
  }

  @override
  void onTapDown(TapDownInfo event) {
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

**Note**: `HasTapableComponents` uses an advanced gesture detector under the hood and as explained
further up on this page it shouldn't be used alongside basic detectors.

### Draggable components

Just like with `Tapable`, Flame offers a mixin for `Draggable`.

By adding the `HasDraggableComponents` mixin to your game, and by using the mixin `Draggable` on
your components, they can override the simple methods that enable an easy to use drag api on your
components.

```dart
  void onDragStart(int pointerId, Vector2 startPosition) {}
  void onDragUpdate(int pointerId, DragUpdateInfo event) {}
  void onDragEnd(int pointerId, DragEndInfo event) {}
  void onDragCancel(int pointerId) {}
```

Note that all events take a uniquely generated pointer id so you can, if desired, distinguish
between different simultaneous drags.

The default implementation provided by `Draggable` will already check:

 - upon drag start, the component only receives the event if the position is within its bounds; keep
 track of pointerId.
 - when handling updates/end/cancel, the component only receives the event if the pointerId was
 tracked (regardless of position).
 - on end/cancel, stop tracking pointerId.

Minimal component example (this example ignores pointerId so it wont work well if you try to
multi-drag):

```dart
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/draggable.dart';

class DraggableComponent extends PositionComponent with Draggable {

  // update and render omitted

  Vector2 dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  @override
  bool onDragStart(int pointerId, Vector2 startPosition) {
    dragDeltaPosition = startPosition - position;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo event) {
    final localCoords = event.eventPosition.game;
    position = localCoords - dragDeltaPosition;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo event) {
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    dragDeltaPosition = null;
    return false;
  }
}

class MyGame extends BaseGame with HasDraggableComponents {
  MyGame() {
    add(DraggableComponent());
  }
}
```

**Note**: `HasDraggableComponents` uses an advanced gesture detector under the hood and as explained
further up on this page, shouldn't be used alongside basic detectors.

## Hitbox
The `Hitbox` mixin is used to make detection of gestures on top of your `PositionComponent`s more
accurate. Say that you have a fairly round rock as a `SpriteComponent` for example, then you don't
want to register input that is in the corner of the image where the rock is not displayed. Then you
can use the `Hitbox` mixin to define a more accurate polygon for which the input should be within
for the event to be counted on your component.

An example of you to use it can be seen
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/).

## Keyboard

Flame provides a simple way to access Flutter's features regarding accessing Keyboard input events.

To use it, just add the `KeyboardEvents` mixin to your game class.
When doing this you will need to implement the `onKeyEvent` method, this method is called every time
a keyboard event happens, and it receives an instance of the Flutter class `RawKeyEvent`.
This event can be used to get information about what occurred, such as if it was a key down or key
up event, and which key was pressed etc.

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

You can also check a more complete example
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/controls/keyboard.dart).

## Joystick

Flame provides a component capable of creating a virtual joystick for taking input for your game. It
can be configured with a variety of combinations, like using two sticks, or only one stick and some
pressable buttons, and so on.

To use this feature. You need to create a `JoystickComponent`, configure it the way you want, and
add it to your game.

To receive the inputs from the joystick component, you need to have a class which implements a
`JoystickListener`, and that class needs to be added as an observer of the joystick component
previous created. That implementation of the the `JoystickListener` could be any class, but one
common practice is for it to be your component that will be controlled by the joystick, like a
player component for example.

Check this example to get a better understanding:

```dart
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/joystick/joystick.dart';
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

You can also check a more complete example
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/controls/joystick.dart).

## Gamepad

Flame has a separate plugin for gamepad support, you can checkout the plugin
[here](https://github.com/flame-engine/flame_gamepad) for more information.
