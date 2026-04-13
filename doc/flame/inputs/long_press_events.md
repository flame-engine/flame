# Long Press Events

**Long press events** occur when the user presses and holds a pointer (finger or mouse) on a
component for a sustained period. This gesture is commonly used for context menus, drag-to-move
behaviors, or any action that requires a deliberate, sustained touch.

For components that should respond to long press events, add the `LongPressCallbacks` mixin.

- This mixin adds four overridable methods to your component: `onLongPressStart`,
  `onLongPressMoveUpdate`, `onLongPressEnd`, and `onLongPressCancel`.
- By default, `isLongPressing` is tracked automatically and can be accessed by your component.
- The component must implement `containsLocalPoint()` (already implemented in `PositionComponent`,
  so most of the time you don't need to do anything here). This method allows Flame to know whether
  the event occurred within the component or not. You can override it to `true` to receive all
  long press events regardless of position.

```dart
class MyComponent extends PositionComponent with LongPressCallbacks {
  MyComponent() : super(size: Vector2.all(32));

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event); // handles internal updating of isLongPressing
    // Do something when the long press is recognized
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event); // handles internal updating of isLongPressing
    // Do something when the long press finishes
  }
}
```


## Long press anatomy


### onLongPressStart

The first event in a long press sequence. It fires once the pointer has been held down long enough
to be recognized as a long press. By default, Flutter's `LongPressGestureRecognizer` uses
`kLongPressTimeout` (500ms) as a long press definition.

The `LongPressStartEvent` provides the position of the contact point in multiple coordinate
systems: `devicePosition` (device coordinates), `canvasPosition` (game widget coordinates), and
`localPosition` (component-local coordinates).

Any component that receives `onLongPressStart` will later receive either `onLongPressEnd` (on
success) or `onLongPressCancel` (if cancelled). Move updates may also be delivered in between.

Calling `super.onLongPressStart(event)` sets `isLongPressing` to `true`.


### onLongPressMoveUpdate

Fires continuously as the user moves their finger during an active long press. This event is only
delivered to components that received the initial `onLongPressStart`.

The `LongPressMoveUpdateEvent` is a `DisplacementEvent` that provides a frame-to-frame delta,
just like `DragUpdateEvent`. That means you can use `localDelta` to move a component following
the pointer (it correctly accounts for camera zoom and component transforms).
The event also carries `offsetFromOrigin` for the total displacement since the gesture started.


### onLongPressEnd

Fires when the user lifts their pointer after a long press. The `LongPressEndEvent` includes the
final position and the `velocity` of the pointer at the moment of release.

Calling `super.onLongPressEnd(event)` sets `isLongPressing` to `false`.


### onLongPressCancel

Fires if the gesture is interrupted before completing (e.g. by a competing gesture recognizer).

Calling `super.onLongPressCancel(event)` sets `isLongPressing` to `false`.


## Mixins


### LongPressCallbacks

The `LongPressCallbacks` mixin can be added to any `Component` for that component to start
receiving long press events.

This mixin adds methods `onLongPressStart`, `onLongPressMoveUpdate`, `onLongPressEnd`, and
`onLongPressCancel` to the component. Override them to implement behavior.

A component will only receive long press events that originate *within* that component, as judged
by the `containsLocalPoint()` function. The commonly-used `PositionComponent` class provides such
an implementation based on its `size` property.

The mixin also provides an `isLongPressing` property that tracks whether a long press gesture
is currently active on the component. This is managed automatically when you call `super` in
`onLongPressStart`, `onLongPressEnd`, and `onLongPressCancel`.

```dart
class LongPressSquare extends RectangleComponent with LongPressCallbacks {
  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    paint.color = Colors.red;
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event);
    paint.color = Colors.blue;
  }
}
```
