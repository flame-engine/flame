# Drag Events

**Drag events** occur when the user moves their finger across the screen of the device, or when they
move the mouse while holding its button down.

Multiple drag events can occur at the same time, if the user is using multiple fingers. Such cases
will be handled correctly by Flame, and you can even keep track of the events by using their
`pointerId` property.

For those components that you want to respond to drags, add the `DragCallbacks` mixin.

- This mixin adds four overridable methods to your component: `onDragStart`, `onDragUpdate`,
  `onDragEnd`, and `onDragCancel`. By default, these methods do nothing; they need to be overridden
  in order to perform any function.
- In addition, the component must implement the `containsLocalPoint()` method (already implemented
  in `PositionComponent`, so most of the time you don't need to do anything here). This method
  allows Flame to know whether the event occurred within the component or not.

```dart
class MyComponent extends PositionComponent with DragCallbacks {
  MyComponent() : super(size: Vector2(180, 120));

   @override
   void onDragStart(DragStartEvent event) {
     // Do something in response to a drag event
   }
}
```


## Demo

In this example you can use drag gestures to either drag star-like shapes across the screen, or to
draw curves inside the magenta rectangle.

```{flutter-app}
:sources: ../flame/examples
:page: drag_events
:show: widget code
```


## Drag anatomy


### onDragStart

This is the first event that occurs in a drag sequence. Usually, the event will be delivered to the
topmost component at the point of touch with the `DragCallbacks` mixin. However, by setting the flag
`event.continuePropagation` to true, you can allow the event to propagate to the components below.

The `DragStartEvent` object associated with this event will contain the coordinate of the point
where the event has originated. This point is available in multiple coordinate system:
`devicePosition` is given in the coordinate system of the entire device, `canvasPosition` is in the
coordinate system of the game widget, and `localPosition` provides the position in the component's
local coordinate system.

Any component that receives `onDragStart` will later be receiving `onDragUpdate` and `onDragEnd`
events as well.


### onDragUpdate

This event is fired continuously as user drags their finger across the screen. It will not fire if
the user is holding their finger still.

The default implementation delivers this event to all the components that received the previous
`onDragStart` with the same pointer id. If the point of touch is still within the component, then
`event.localPosition` will give the position of that point in the local coordinate system. However,
if the user moves their finger away from the component, the property `event.localPosition` will
return a point whose coordinates are NaNs. Likewise, the `event.renderingTrace` in this case will be
empty. However, the `canvasPosition` and `devicePosition` properties of the event will be valid.

In addition, the `DragUpdateEvent` will contain `delta`, the amount the finger has moved since
the previous `onDragUpdate`, or since the `onDragStart` if this is the first drag-update after
a drag-start.

The `event.timestamp` property measures the time elapsed since the beginning of the drag. It can be
used, for example, to compute the speed of the movement.


### onDragEnd

This event is fired when the user lifts their finger and thus stops the drag gesture. There is no
position associated with this event.


### onDragCancel

This event is fired when the drag gesture is interrupted before it ends naturally, for example when
another gesture recognizer wins the gesture arena or a second pointer triggers a scale takeover.
Unlike `onDragEnd` it carries no velocity information. The default implementation simply resets the
drag state; override it and call `onDragEnd` yourself if you want a cancellation handled identically
to a natural drag end.


## Mixins


### DragCallbacks

The `DragCallbacks` mixin can be added to any `Component` in order for that component to start
receiving drag events.

This mixin adds methods `onDragStart`, `onDragUpdate`, `onDragEnd`, and `onDragCancel` to the
component, which by default don't do anything, but can be overridden to implement any real
functionality.

Another crucial detail is that a component will only receive drag events that originate *within*
that component, as judged by the `containsLocalPoint()` function. The commonly-used
`PositionComponent` class provides such an implementation based on its `size` property. Thus, if
your component derives from a `PositionComponent`, then make sure that you set its size correctly.
If, however, your component derives from the bare `Component`, then the `containsLocalPoint()`
method must be implemented manually.

If your component is a part of a larger hierarchy, then it will only receive drag events if its
ancestors have all implemented the `containsLocalPoint` correctly.


### isDragged

The `DragCallbacks` mixin provides an `isDragged` getter that returns `true` while the component is
actively being dragged. This is set to `true` at `onDragStart` and back to `false` at `onDragEnd`.
It can be used, for example, to change the component's visual appearance during a drag.


## Combining with ScaleCallbacks

A component can use both `DragCallbacks` and `ScaleCallbacks` at the same time. When both mixins are
present, single-finger gestures produce drag events and two-finger gestures produce both drag and
scale events. This is useful for components that should be draggable with one finger and
pinch-to-zoom or rotatable with two fingers.

```dart
class InteractiveRectangle extends RectangleComponent
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
