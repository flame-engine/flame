# Scale Events

**Scale events** occur when the user moves two fingers in a pinch in, or in a pinch out move.
Only one single scale gesture can occur at the same time.

For those components that you want to respond to scale events, add the `ScaleCallbacks` mixin.

- This mixin adds three overridable methods to your component: `onScaleStart`, `onScaleUpdate`,
  `onScaleEnd`. By default, these methods do nothing -- they need to be
  overridden in order to perform any function.
- In addition, the component must implement the `containsLocalPoint()` method (already implemented
  in `PositionComponent`, so most of the time you don't need to do anything here) -- this method
  allows Flame to know whether the event occurred within the component or not.

```dart
class MyComponent extends PositionComponent with ScaleCallbacks {
  MyComponent() : super(size: Vector2(180, 120));

   @override
   void onScaleStart(ScaleStartEvent event) {
     // Do something in response to a scale event
   }
}
```


## Scale anatomy


### onScaleStart

This is the first event that occurs in a scale sequence. Usually, the event will be delivered to the
topmost component at the focal point (the point at the center of the line formed by the two fingers)
 with the `ScaleCallbacks` mixin. However, by setting the flag
`event.continuePropagation` to true, you can allow the event to propagate to the components below.

The `ScaleStartEvent` object associated with this event will contain
the coordinate of the first focal point
recognized by the scale gesture recognizer. This point is available in multiple coordinate system:
`devicePosition` is given in the coordinate system of the entire device, `canvasPosition` is in the
coordinate system of the game widget, and `localPosition` provides the position in the component's
local coordinate system.

Any component that receives `onScaleStart` will later be receiving `onScaleUpdate` and `onScaleEnd`
events as well.


### onScaleUpdate

This event is fired continuously as user drags their finger across the screen. It will not fire if
the user is holding their finger still.

The default implementation delivers this event to all the components that received the previous
`onScaleStart`. If the point of touch is still within the component, then
`event.localPosition` will give the position of that point in the local coordinate system. However,
if the user moves their finger away from the component, the property `event.localPosition` will
return a point whose coordinates are NaNs. Likewise, the `event.renderingTrace` in this case will be
empty. However, the `canvasPosition` and `devicePosition` properties of the event will be valid.

In addition, the `ScaleUpdateEvent` will contain `focalPointDelta` --
the amount the focal point has moved since the
previous `onScaleUpdate`, or since the `onScaleStart` if this is the first scale-update after a scale-
start.

The `event.timestamp` property measures the time elapsed since the beginning of the scale. It can be
used, for example, to compute the speed of the movement.

The `event.rotation` property measures the angle of rotation in radians, between the line formed
from the two fingers at the start, and the line formed when this event is called.

The `event.scale` property measures the ratio of length between the line formed
from the two fingers at the start, and the line formed when this event is called.


### onScaleEnd

This event is fired when the user lifts their finger and thus stops the scale gesture. There is no
position associated with this event.


## Mixins


### ScaleCallbacks

The `ScaleCallbacks` mixin can be added to any `Component` in order for that component to start
receiving scale events.

This mixin adds methods `onScaleStart`, `onScaleUpdate`, `onScaleEnd` to the
component, which by default don't do anything, but can be overridden to implement any real
functionality.

Another crucial detail is that a component will only receive scale events that originate *within*
that component, as judged by the `containsLocalPoint()` function. The commonly-used
`PositionComponent` class provides such an implementation based on its `size` property. Thus, if
your component derives from a `PositionComponent`, then make sure that you set its size correctly.
If, however, your component derives from the bare `Component`, then the `containsLocalPoint()`
method must be implemented manually.

If your component is a part of a larger hierarchy, then it will only receive scale events if its
ancestors have all implemented the `containsLocalPoint` correctly.

```dart
class ScaleOnlyRectangle extends RectangleComponent with ScaleCallbacks {
  ScaleOnlyRectangle({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.blue,
    Anchor anchor = Anchor.center,
  }) : super(
         position: position,
         size: size,
         anchor: anchor,
         paint: Paint()..color = color,
       );

  @override
  Future<void> onLoad() async {
    final text = TextComponent(
      text: 'scale',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  bool isScaling = false;
  double initialAngle = 0;
  Vector2 initialScale = Vector2.all(1);
  double lastScale = 1.0;

  /// ScaleCallbacks overrides
  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    isScaling = true;
    initialAngle = angle;
    initialScale = scale;
    lastScale = 1.0;
    debugPrint('Scale started at ${event.devicePosition}');
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    // scale rectangle size by pinch
    angle = initialAngle + event.rotation;
    // delta scale since last frame
    if (lastScale == 0) {
      return;
    }
    final scaleDelta = event.scale / lastScale;
    lastScale = event.scale; // update for next frame

    // apply delta gently
    scale *= sqrt(scaleDelta);

    // clamp
    scale.clamp(Vector2.all(0.8), Vector2.all(3));
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    isScaling = false;
    debugPrint('Scale ended with velocity ${event.velocity}');
  }
}

```


## Scale and drag gestures interactions

A multi drag gesture can sometimes look exactly like a scale gesture.
This is the case for instance, if you try to move two components toward each other at the same time.
If you added both a component using ScaleCallbacks and
one using DragCallbacks (or one using both), this issue will arise.
The Scale gesture will win over the drag gesture
and prevent your user to perform the multi drag gesture as they wanted. This is a limitation
with the current implementation that devs need to be aware of.
