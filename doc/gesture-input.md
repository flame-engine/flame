# Gesture Input

This includes documentation for gesture inputs, which is, mouse and touch pointers.

For other input documents, see also:

- [Keyboard Input](keyboard-input.md): for keystrokes
- [Other Inputs](other-inputs.md): For joysticks, game pads, etc.

## Intro

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

It is also possible to change the current mouse cursor displayed on the `GameWidget` region. To do
so the following code can be used inside the `Game` class

```dart
mouseCursor.value = SystemMouseCursors.move;
```

To already initialize the `GameWidget` with a custom cursor, the `mouseCursor` property can be used

```dart
GameWidget(
  game: MouseCursorGame(),
  mouseCursor: SystemMouseCursors.move,
);
```

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
  bool onTapDown(TapDownInfo event) {
    print("Player tap down on ${event.eventPosition.game}");
    return true;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    print("Player tap up on ${event.eventPosition.game}");
    return true;
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
bool onTapCancel();
bool onTapDown(TapDownInfo event);
bool onTapUp(TapUpInfo event);
```

Minimal component example:

```dart
import 'package:flame/components.dart';

class TappableComponent extends PositionComponent with Tappable {

  // update and render omitted

  @override
  bool onTapUp(TapUpInfo event) {
    print("tap up");
    return true;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    print("tap down");
    return true;
  }

  @override
  bool onTapCancel() {
    print("tap cancel");
    return true;
  }
}

class MyGame extends FlameGame with HasTappableComponents {
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
  bool onDragStart(int pointerId, Vector2 startPosition);
  bool onDragUpdate(int pointerId, DragUpdateInfo event);
  bool onDragEnd(int pointerId, DragEndInfo event);
  bool onDragCancel(int pointerId);
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

class MyGame extends FlameGame with HasDraggableComponents {
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


