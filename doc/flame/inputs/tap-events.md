# Tap events

```{note}
This document describes a new experimental API. The more traditional approach
for handling tap events is described in [](gesture-input.md).
```

**Tap events** are one of the most basic methods of interaction with a Flame game. These events
occur when the user touches the screen with a finger, or clicks with a mouse, or taps with a stylus.
A tap can be "long", but the finger isn't supposed to move during the gesture. Thus, touching the
screen, then moving the finger, and then releasing -- is not a tap but a drag.

Multiple tap events can occur at the same time, especially if the user has multiple fingers. Such
cases will be handled correctly by Flame, and you can even keep track of the events by using their
`pointerId` property.

It takes only a few simple steps to enable these events for your game:

1.  Add the `HasTappableComponents` mixin to your main game class.
    - This mixin works "as-is", and doesn't need to be configured further.

2.  For those components that you want to respond to taps, add the `TapCallbacks` mixin.
    - This mixin adds four overridable methods to your component: `onTapDown`, `onTapUp`,
      `onTapCancel`, and `onLongTapDown`. By default, each of these methods does nothing, they need
      to be overridden in order to perform any function.
    - In addition, the component must implement the `containsLocalPoint()` method -- this method
      allows Flame to know whether the event occurred within the component or not.


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
be generated at all: it will be replaced with `onTapCancel`.


### onTapCancel

This event occurs when the tap fails to materialize. Most often, this will happen if the user moves
their finger, which converts the gesture from "tap" into "drag". Less often, this may happen when
the component being tapped moves away from under the user's finger.

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
