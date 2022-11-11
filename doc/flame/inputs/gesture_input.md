# Gesture Input

This includes documentation for gesture inputs, which is, mouse and touch pointers.

For other input documents, see also:

- [Keyboard Input](keyboard_input.md): for keystrokes
- [Other Inputs](other_inputs.md): For joysticks, game pads, etc.


## Intro

Inside `package:flame/gestures.dart` you can find a whole set of `mixin`s which can be included on
your game class instance to be able to receive touch input events. Below you can see the full list
of these `mixin`s and its methods:


## Touch and mouse detectors

```text
- TapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onLongTapDown
  - onTapUp

- SecondaryTapDetector
  - onSecondaryTapDown
  - onSecondaryTapUp
  - onSecondaryTapCancel

- TertiaryTapDetector
  - onTertiaryTapDown
  - onTertiaryTapUp
  - onTertiaryTapCancel

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

```text
 - MouseMovementDetector
  - onMouseMove
 - ScrollDetector
  - onScroll
```


It is not possible to mix advanced detectors (`MultiTouch*`) with basic detectors of the same
kind, since the advanced detectors will *always win the gesture arena* and the basic detectors will
never be triggered. So for example, you can't use both `MultiTouchTapDetector` and `PanDetector`
together, since no events will be triggered for the latter (there is also an assertion for this).

Flame's GestureApi is provided by Flutter's Gesture Widgets, including
[GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html)
and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html), you can
also read more about Flutter's gestures
[here](https://api.flutter.dev/flutter/gestures/gestures-library.html).


## PanDetector and ScaleDetector

If you add a `PanDetector` together with a `ScaleDetector` you will be prompted with a quite cryptic
assertion from Flutter that says:

```{note}
Having both a pan gesture recognizer and a scale gesture recognizer is
redundant; scale is a superset of pan.

Just use the scale gesture recognizer.
```

This might seem strange, but `onScaleUpdate` is not only triggered when the scale should be changed,
but for all pan/drag events too. So if you need to use both of those detectors you'll have to handle
both of their logic inside `onScaleUpdate` (+`onScaleStart` and `onScaleEnd`).

For example you could do something like this if you want to move the camera on pan events and zoom
on scale events:

```dart
  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.zoom = startZoom * currentScale.y;
    } else {
      camera.translateBy(-info.delta.game);
      camera.snap();
    }
  }
```

In the example above the pan events are handled with `info.delta` and the scale events with
`info.scale`, although they are theoretically both from underlying scale events.

This can also be seen in the
[zoom example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/zoom_example.dart).


## Mouse cursor

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
  bool onTapDown(TapDownInfo info) {
    print("Player tap down on ${info.eventPosition.game}");
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    print("Player tap up on ${info.eventPosition.game}");
    return true;
  }
}
```

You can also check more complete examples
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/).


## Tappable, Draggable and Hoverable components

Any component derived from `Component` (most components) can add the `Tappable`, the
`Draggable`, and/or the `Hoverable` mixins to handle taps, drags and hovers on the component.

All overridden methods return a boolean to control if the event should be passed down further along
to components underneath it. So say that you only want your top visible component to receive a tap
and not the ones underneath it, then your `onTapDown`, `onTapUp` and `onTapCancel` implementations
should return `false` and if you want the event to go through more of the components underneath then
you should return `true`.

The same applies if your component has children, then the event is first sent to the leaves in the
children tree and then passed further down until a method returns `false`.


### Tappable components

By adding the `HasTappables` mixin to your game, and using the mixin `Tappable` on your
components, you can override the following methods on your components:

```dart
bool onTapCancel();
bool onTapDown(TapDownInfo info);
bool onLongTapDown(TapDownInfo info);
bool onTapUp(TapUpInfo info);
```

Minimal component example:

```dart
import 'package:flame/components.dart';

class TappableComponent extends PositionComponent with Tappable {

  // update and render omitted

  @override
  bool onTapUp(TapUpInfo info) {
    print("tap up");
    return true;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    print("tap down");
    return true;
  }

  @override
  bool onTapCancel() {
    print("tap cancel");
    return true;
  }
}

class MyGame extends FlameGame with HasTappables {
  MyGame() {
    add(TappableComponent());
  }
}
```

**Note**: `HasTappables` uses an advanced gesture detector under the hood and as explained
further up on this page it shouldn't be used alongside basic detectors.

To recognize whether a `Tappable` added to the game handled an event, the `handled` field can be set
to true in the event can be checked in the corresponding method in the game class, or further down
the chain if you let the event continue to propagate.

In the following example it can be seen how it is used with `onTapDown`, the same technique can also
be applied to `onTapUp`.

```dart
class MyComponent extends PositionComponent with Tappable{
  @override
  bool onTapDown(TapDownInfo info) {
    info.handled = true;
    return true;
  }
}

class MyGame extends FlameGame with HasTappables {
  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (info.handled) {
      // Do something if a child handled the event
    }
  }
}
```

The event `onLongTapDown` will be triggered on a component after the user "holds" it for a certain
minimum amount of time. By default, that time is 300ms, but it can be adjusted by overriding the
`longTapDelay` field of the `HasTappables` mixin.


### Draggable components

Just like with `Tappable`, Flame offers a mixin for `Draggable`.

By adding the `HasDraggables` mixin to your game, and by using the mixin `Draggable` on
your components, they can override the simple methods that enable an easy to use drag api on your
components.

```dart
  bool onDragStart(DragStartInfo info);
  bool onDragUpdate(DragUpdateInfo info);
  bool onDragEnd(DragEndInfo info);
  bool onDragCancel();
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

  Vector2? dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  bool onDragStart(DragStartInfo startPosition) {
    dragDeltaPosition = startPosition.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo event) {
    if (isDragging) {
      final localCoords = event.eventPosition.game;
      position = localCoords - dragDeltaPosition!;
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo event) {
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel() {
    dragDeltaPosition = null;
    return false;
  }
}

class MyGame extends FlameGame with HasDraggables {
  MyGame() {
    add(DraggableComponent());
  }
}
```

To recognize whether a `Draggable` added to the game handled an event, the `handled` field can be
set to true in the event can be checked in the corresponding method in the game class, or further
down the chain if you let the event continue to propagate.

In the following example it can be seen how it is used with `onDragStart`, the same technique can
also be applied to `onDragUpdate` and `onDragEnd`.

```dart
class MyComponent extends PositionComponent with Draggable {
 @override
 bool onDragStart(DragStartInfo info) {
   info.handled = true;
   return true;
 }
}

class MyGame extends FlameGame with HasDraggables {
  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    if (info.handled) {
      // Do something if a child handled the event
    }
  }
}
```


### Hoverable components

Just like the others, this mixin allows for easy wiring of your component to listen to hover states
and events.

By adding the `HasHoverables` mixin to your base game, and by using the mixin `Hoverable` on
your components, they get an `isHovered` field and a couple of methods (`onHoverStart`,
`onHoverEnd`) that you can override if you want to listen to the events.

```dart
  bool isHovered = false;
  bool onHoverEnter(PointerHoverInfo info) {
    print("hover enter");
    return true;
  }
  bool onHoverLeave(PointerHoverInfo info) {
   print("hover leave");
   return true;
  }
```

The provided event info is from the mouse move that triggered the action (entering or leaving).
While the mouse movement is kept inside or outside, no events are fired and those mouse move events are
not propagated. Only when the state is changed the handlers are triggered.

To recognize whether a `Hoverable` added to the game handled an event, the `handled` field can be
set to true in the event can be checked in the corresponding method in the game class, or further
down the chain if you let the event continue to propagate.

In the following example it can be seen how it is used with `onHoverEnter`, the same technique can
also be applied to `onHoverLeave`.

```dart
class MyComponent extends PositionComponent with Hoverable {
  @override
  bool onHoverEnter(PointerHoverInfo info) {
    info.handled = true;
    return true;
  }
}

class MyGame extends FlameGame with HasHoverables {
  @override
  void onHoverEnter(PointerHoverInfo info) {
    if (info.handled) {
      // Do something if a child handled the event
    }
  }
}
```


### GestureHitboxes

The `GestureHitboxes` mixin is used to more accurately recognize gestures on top of your
`Component`s. Say that you have a fairly round rock as a `SpriteComponent` for example, then you
don't want to register input that is in the corner of the image where the rock is not displayed,
since a `PositionComponent` is rectangular by default. Then you can use the `GestureHitboxes` mixin
to define a more accurate circle or polygon (or another shape) for which the input should be within
for the event to be registered on your component.

You can add new hitboxes to the component that has the `GestureHitboxes` mixin just like they are
added in the below `Collidable` example.

More information about how to define hitboxes can be found in the hitbox section of the
[collision detection](../collision_detection.md#shapehitbox) docs.

An example of how to use it can be seen
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/gesture_hitboxes_example.dart).
