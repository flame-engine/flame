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

## Tappable, Draggable and Hoverable components

Any component derived from `BaseComponent` (most components) can add the `Tappable`, the
`Draggable`, and/or the `Hoverable` mixins to handle taps, drags and hovers on the component.

All overridden methods return a boolean to control if the event should be passed down further along
to components underneath it. So say that you only want your top visible component to receive a tap
and not the ones underneath it, then your `onTapDown`, `onTapUp` and `onTapCancel` implementations
should return `false` and if you want the event to go through more of the components underneath then
you should return `true`.

The same applies if your component has children, then the event is first sent to the leaves in the
children tree and then passed further down until a method returns `false`.

### Tappable components

By adding the `HasTappableComponents` mixin to your game, and using the mixin `Tappable` on your
components, you can override the following methods on your components:

```dart
void onTapCancel() {}
void onTapDown(TapDownInfo event) {}
void onTapUp(TapUpInfo event) {}
```

Minimal component example:

```dart
import 'package:flame/components.dart';

class TappableComponent extends PositionComponent with Tappable {

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

class MyGame extends BaseGame with HasTappableComponents {
  MyGame() {
    add(TappableComponent());
  }
}
```

**Note**: `HasTappableComponents` uses an advanced gesture detector under the hood and as explained
further up on this page it shouldn't be used alongside basic detectors.

### Draggable components

Just like with `Tappable`, Flame offers a mixin for `Draggable`.

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
import 'package:flame/components.dart';

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

### Hoverable components

Just like the others, this mixin allows for easy wiring of your component to listen to hover states
and events.

By adding the `HasHoverableComponents` mixin to your base game, and by using the mixin `Hoverable` on
your components, they get an `isHovered` field and a couple of methods (`onHoverStart`, `onHoverEnd`) that
you can override if you want to listen to the events.

```dart
  bool isHovered = false;
  void onHoverEnter(PointerHoverInfo event) {}
  void onHoverLeave(PointerHoverInfo event) {}
```

The provided event info is from the mouse move that triggered the action (entering or leaving).
While the mouse movement is kept inside or outside, no events are fired and those mouse move events are
not propagated. Only when the state is changed the handlers are triggered.

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
import 'package:flame/input.dart';
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
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/keyboard.dart).

## Joystick

Flame provides a component capable of creating a virtual joystick for taking input for your game.
To use this feature you need to create a `JoystickComponent`, configure it the way you want, and
add it to your game.

To receive the inputs from the joystick component, pass your `JoystickComponent` to the component
that you want it to control, or simply act upon input from it in the update-loop of your game.

Check this example to get a better understanding:

```dart
class MyGame extends BaseGame with HasDraggableComponents {

  MyGame() {
    joystick.addObserver(player);
    add(player);
    add(joystick);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );
    final joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2.all(100),
      ),
      background: SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2.all(150),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    final player = Player(joystick);
    add(player);
    add(joystick);
  }
}

class JoystickPlayer extends SpriteComponent with HasGameRef {
  /// Pixels/s
  double maxSpeed = 300.0;

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick)
      : super(
          size: Vector2.all(100.0),
        ) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('layers/player.png');
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (joystick.direction != JoystickDirection.idle) {
      position.add(joystick.velocity * maxSpeed * dt);
      angle = joystick.delta.screenAngle();
    }
  }
}
```

So in this example we create the classes `MyGame` and `Player`. `MyGame` creates a joystick which is
passed to the `Player` when it is created. In the `Player` class we act upon the current state of
the joystick.

The joystick has a few fields that change depending on what state it is in.
These are the fields that should be used to know the state of the joystick:
 - `intensity`: The percentage [0.0, 1.0] that the knob is dragged from the epicenter to the edge of
  the joystick (or `knobRadius` if that is set).
 - `delta`: The absolute amount (defined as a `Vector2`) that the knob is dragged from its epicenter.
 - `velocity`: The percentage, presented as a `Vector2`, and direction that the knob is currently
  pulled from its base position to a edge of the joystick.

If you want to create buttons to go with your joystick, check out
[`MarginButtonComponent`](#HudButtonComponent).

A full examples of how to use it can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/joystick.dart).
And it can be seen running [here](https://examples.flame-engine.org/#/Controls_Joystick).

## HudButtonComponent
A `HudButtonComponent` is a button that can be defined with margins to the edge of the `Viewport`
instead of with a position. It takes two `PositionComponent`s. `button` and `buttonDown`, the first
is used for when the button is idle and the second is shown when the button is being pressed. The
second one is optional if you don't want to change the look of the button when it is pressed, or if
you handle this through the `button` component.

As the name suggests this button is a hud by default, which means that it will be static on your
screen even if the camera for the game moves around. You can also use this component as a non-hud by
setting `hudButtonComponent.isHud = false;`.

If you want to act upon the button being pressed (which I guess that you do) you can either pass in
a callback function as the `onPressed` argument, or you extend the component and override
`onTapDown`, `onTapUp` and/or `onTapCancel` and implement your logic in there.

## Gamepad

Flame has a separate plugin for gamepad support, you can checkout the plugin
[here](https://github.com/flame-engine/flame_gamepad) for more information.
