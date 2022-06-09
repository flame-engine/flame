# Drag events

```{note}
This document describes a new experimental API. The more traditional approach
for handling drag events is described in [](gesture-input.md).
```

**Drag events** occur when the user moves their finger across the screen of the device, or when they
move the mouse while holding its button down.

Multiple drag events can occur at the same time, if the user is using multiple fingers. Such cases
will be handled correctly by Flame, and you can even keep track of the events by using their
`pointerId` property.

In order to enable drag events for your game, do the following:

1.  Add the `HasDraggableComponents` mixin to your main game class:
    ```dart
    class MyGame extends FlameGame with HasDraggableComponents {
     // ...
    }
    ```

2.  For those components that you want to respond to drags, add the `DragCallbacks` mixin.
    - This mixin adds four overridable methods to your component: `onDragStart`, `onDragUpdate`,
      `onDragEnd`, and `onDragCancel`. By default, these methods do nothing -- they need to be
      overridden in order to perform any function.
    - In addition, the component must implement the `containsLocalPoint()` method -- this method
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
draw curves inside the pink rectangle.

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

In addition, the `DragUpdateEvent` will contain `delta` -- the amount the finger has moved since the
previous `onDragUpdate`, or since the `onDragStart` if this is the first drag-update after a drag-
start.

The `event.timestamp` property measures the time elapsed since the beginning of the drag. It can be
used, for example, to compute the speed of the movement.


### onDragEnd

This event is fired when the user lifts their finger and thus stops the drag gesture. There is no
position associated with this event.


### onDragCancel

The precise semantics when this event occurs is not clear, so we provide a default implementation
which simply converts this event into an `onDragEnd`.


## Mixins

### HasDraggableComponents
