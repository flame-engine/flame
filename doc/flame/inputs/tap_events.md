# Tap Events

```{note}
This document describes a new experimental API. The more traditional approach
for handling tap events is described in [](gesture_input.md).
```

**Tap events** are one of the most basic methods of interaction with a Flame game. These events
occur when the user touches the screen with a finger, or clicks with a mouse, or taps with a stylus.
A tap can be "long", but the finger isn't supposed to move during the gesture. Thus, touching the
screen, then moving the finger, and then releasing -- is not a tap but a drag. Similarly, clicking
a mouse button while the mouse is moving will also be registered as a drag.

Multiple tap events can occur at the same time, especially if the user has multiple fingers. Such
cases will be handled correctly by Flame, and you can even keep track of the events by using their
`pointerId` property.

It takes only a few simple steps to enable these events for your game:

1. Add the `HasTappableComponents` mixin to your main game class:

    ```dart
    class MyGame extends FlameGame with HasTappableComponents {
      // ...
    }
    ```

2. For those components that you want to respond to taps, add the `TapCallbacks` mixin.
    - This mixin adds four overridable methods to your component: `onTapDown`, `onTapUp`,
      `onTapCancel`, and `onLongTapDown`. By default, each of these methods does nothing, they need
      to be overridden in order to perform any function.
    - In addition, the component must implement the `containsLocalPoint()` method -- this method
      allows Flame to know whether the event occurred within the component or not.

    ```dart
    class MyComponent extends PositionComponent with TapCallbacks {
      MyComponent() : super(size: Vector2(80, 60));

      @override
      void onTapUp(TapUpEvent event) {
        // Do something in response to a tap
      }
    }
    ```


## Tap anatomy


### onTapDown

Every tap begins with a "tap down" event, which you receive via the `void onTapDown(TapDownEvent)`
handler. The event is delivered to the first component located at the point of touch that has the
`TapCallbacks` mixin. Normally, the event then stops propagation. However, you can force the event
to also be delivered to the components below by setting `event.continuePropagation` to true.

The `TapDownEvent` object that is passed to the event handler, contains the available information
about the event. For example, `event.localPosition` will contain the coordinate of the event in the
current component's local coordinate system, whereas `event.canvasPosition` is in the coordinate
system of the entire game canvas.

Every component that received an `onTapDown` event will eventually receive either `onTapUp` or
`onTapCancel` with the same `pointerId`.


### onLongTapDown

If the user holds their finger down for some time (as configured by the `.longTapDelay` property
in `HasTappableComponents`), the "long tap" will be generated. This event invokes the
`void onLongTapDown(TapDownEvent)` handler on those components that previously received the
`onTapDown` event.


### onTapUp

This event indicates successful completion of the tap sequence. It is guaranteed to only be
delivered to those components that previously received the `onTapDown` event with the same pointer
id.

The `TapUpEvent` object passed to the event handler contains the information about the event, which
includes the coordinate of the event (i.e. where the user was touching the screen right before
lifting their finger), and the event's `pointerId`.

Note that the device coordinates of the tap-up event will be the same (or very close) to the device
coordinates of the corresponding tap-down event. However, the same cannot be said about the local
coordinates. If the component that you're tapping is moving (as they often tend to in games), then
you may find that the local tap-up coordinates are quite different from the local tap-down
coordinates.

In extreme case, when the component moves away from the point of touch, the `onTapUp` event will not
be generated at all: it will be replaced with `onTapCancel`. Note, however, that in this case the
`onTapCancel` will be generated at the moment the user lifts or moves their finger, not at the
moment the component moves away from the point of touch.


### onTapCancel

This event occurs when the tap fails to materialize. Most often, this will happen if the user moves
their finger, which converts the gesture from "tap" into "drag". Less often, this may happen when
the component being tapped moves away from under the user's finger. Even more rarely, the
`onTapCancel` occurs when another widget pops over the game widget, or when the device turns off,
or similar situations.

The `TapCancelEvent` object contains only the `pointerId` of the previous `TapDownEvent` which is
now being canceled. There is no position associated with a tap-cancel.


### Demo

Play with the demo below to see the tap events in action.

The blue-ish rectangle in the middle is the component that has the `TapCallbacks` mixin. Tapping
this component would create circles at the points of touch. Specifically, `onTapDown` event
starts making the circle. The thickness of the circle will be proportional to the duration of the
tap: after `onTapUp` the circle's stroke width will no longer grow. There will be a thin white
stripe at the moment the `onLongTapDown` fires. Lastly, the circle will implode and disappear if
you cause the `onTapCancel` event by moving the finger.

```{flutter-app}
:sources: ../flame/examples
:page: tap_events
:show: widget code
```


## Mixins

This section describes in more details several mixins needed for tap event handling.


### HasTappableComponents

This mixin is used on a `FlameGame` in order to ensure that tap events coming from Flutter reach
their target `Component`s. This mixin **must** be added if you have any components with the
`TapCallbacks` mixin.

The mixin adds methods `onTapDown`, `onLongTapDown`, `onTapUp`, and `onTapCancel` to the game. The
default implementation will simply propagate these events to the component(s) that are at the point
of touch; but you can override them if you also want to respond to those events at the global game
level:

```dart
class MyGame extends FlameGame with HasTappableComponents {
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!event.handled) {
      print('Event $event was not handled by any component');
    }
  }
}
```


### TapCallbacks

The `TapCallbacks` mixin can be added to any `Component` in order for that component to start
receiving tap events.

This mixin adds methods `onTapDown`, `onLongTapDown`, `onTapUp`, and `onTapCancel` to the component,
which by default don't do anything, but can be overridden to implement any real functionality. There
is no need to override all of them either: for example, you can override only `onTapUp` if you wish
to respond to "real" taps only.

Another crucial detail is that a component will only receive tap events that occur *within* that
component, as judged by the `containsLocalPoint()` function. The commonly-used `PositionComponent`
class provides such an implementation based on its `size` property. Thus, if your component derives
from a `PositionComponent`, then make sure that you set its size correctly. If, however, your
component derives from the bare `Component`, then the `containsLocalPoint()` method must be
implemented manually.

If your component is a part of a larger hierarchy, then it will only receive tap events if its
parent has implemented the `containsLocalPoint` correctly.

```dart
class MyComponent extends Component with TapCallbacks {
  final _rect = const Rect.fromLTWH(0, 0, 100, 100);
  final _paint = Paint();
  bool _isPressed = false;

  @override
  bool containsLocalPoint(Vector2 point) => _rect.contains(point.toOffset());

  @override
  void onTapDown(TapDownEvent event) => _isPressed = true;

  @override
  void onTapUp(TapUpEvent event) => _isPressed = false;

  @override
  void onTapCancel(TapCancelEvent event) => _isPressed = false;

  @override
  void render(Canvas canvas) {
    _paint.color = _isPressed? Colors.red : Colors.white;
    canvas.drawRect(_rect, _paint);
  }
}
```


### HasTappablesBridge

This marker mixin can be used to indicate that the game has both the "new-style" components that
use the `TapCallbacks` mixin, and the "old-style" components that use the `Tappable` mixin. In
effect, every tap event will be propagated twice through the system: first trying to reach the
components with `TapCallbacks` mixin, and then components with `Tappable`.

```dart
class MyGame extends FlameGame with HasTappableComponents, HasTappablesBridge {
  // ...
}
```

The purpose of this mixin is to ease the transition from the old event delivery system to the
new one. With this mixin, you can transition your `Tappable` components into using `TapCallbacks`
one by one, verifying that your game continues to work at every step.

Use of this mixin for any new project is highly discouraged.


## Migration

If you have an existing game that uses `Tappable`/`HasTappables` mixins, then this section will
describe how to transition to the new API described in this document. Here's what you need to do:

1. Replace the `HasTappables` mixin on your game with the pair of mixins `HasTappableComponents,
    HasTappablesBridge`. Verify that your game continues to run as before.

2. Pick any of your components that uses `Tappable`, and replace that mixin with `TapCallbacks`.
    The methods `onTapDown`, `onTapUp`, `onTapCancel` and `onLongTapDown` will need to be adjusted
    for the new API:
    - The argument pair such as `(int pointerId, TapDownDetails details)` was replaced with a single
      event object `TapDownEvent event`.
    - There is no return value anymore, but if you need to make a component to pass-through the taps
      to the components below, then set `event.continuePropagation` to true. This is only needed for
      `onTapDown` events -- all other events will pass-through automatically.
    - If your component needs to know the coordinates of the point of touch, use
      `event.localPosition` instead of computing it manually. Properties `event.canvasPosition` and
      `event.devicePosition` are also available.
    - If the component is a `PositionComponent`, then make sure its size is set correctly (for
      example by turning on the debug mode). If the component does not derive from
      `PositionComponent` then make sure it implements the method `containsLocalPoint()`.
    - If the component is not attached to the root of the game, then make sure its ancestors also
      have correct size or implement `containsLocalPoint()`.

3. Run the game to verify that it works as before.

4. Repeat step 2 until you have converted all `Tappable` mixins into `TapCallbacks`.

5. Remove the `HasTappablesBridge` mixin from your top-level game.
