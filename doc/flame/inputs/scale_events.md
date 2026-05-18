# Scale Events

**Scale events** occur when the user moves two fingers in a pinch in, or in a pinch out move.
Only one single scale gesture can occur at the same time.

For those components that you want to respond to scale events, add the `ScaleCallbacks` mixin.

- This mixin adds three overridable methods to your component: `onScaleStart`, `onScaleUpdate`,
  `onScaleEnd`. By default, these methods do nothing; they need to be overridden in order to
  perform any function.
- In addition, the component must implement the `containsLocalPoint()` method (already implemented
  in `PositionComponent`, so most of the time you don't need to do anything here). This method
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


### isScaling

The `ScaleCallbacks` mixin provides an `isScaling` getter that returns `true` while the component is
actively being scaled. This is set to `true` at the start of `onScaleStart` and back to `false` at
`onScaleEnd`. It can be used, for example, to change the component's visual appearance during a scale
gesture.


### scaleThreshold

Scale events are not fired immediately when two fingers touch the screen. Instead, a small movement
threshold must be crossed first. By default, the fingers must spread or pinch by at least 5% (a
scale factor of 1.05) before `onScaleStart` is called. This prevents accidental scale gestures when
the user simply places two fingers without intending to scale.


## Combining with DragCallbacks

A component can use both `ScaleCallbacks` and `DragCallbacks` at the same time. When both mixins are
present, single-finger gestures produce drag events and two-finger gestures produce both scale and
drag events. This is useful for components that should be draggable with one finger and
pinch-to-zoom or rotatable with two fingers.

```dart
class InteractiveRect extends RectangleComponent
    with ScaleCallbacks, DragCallbacks {

  double _initialAngle = 0;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _initialAngle = angle;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    angle = _initialAngle + event.rotation;
  }
}
```
