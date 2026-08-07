# Migration Guides

This section describes the breaking changes that you need to be aware of when upgrading between
major versions of Flame, together with the steps required to migrate your code.


## Migrating from v1.38.0 to v2.0.0


### `ForcePressDetector` replaced by `ForcePressCallbacks`

Force press was the last gesture that only existed on the old game-level detector API. The
`ForcePressDetector` mixin and its `ForcePressInfo` event class have been removed, and replaced by
the `ForcePressCallbacks` component mixin and the `ForcePressEvent` class, in line with every other
gesture.

The four callbacks keep their names, but they now receive a single `ForcePressEvent` instead of a
`ForcePressInfo`, and they are declared on a component rather than on the game:

```dart
// Before
class MyGame extends FlameGame with ForcePressDetector {
  @override
  void onForcePressUpdate(ForcePressInfo info) {
    final position = info.eventPosition.widget;
    final pressure = info.pressure;
  }
}

// After
class MyComponent extends PositionComponent with ForcePressCallbacks {
  @override
  void onForcePressUpdate(ForcePressEvent event) {
    final position = event.localPosition;
    final pressure = event.pressure;
  }
}
```

As with the other callback mixins, the event is delivered only to components under the point of
contact, `event.localPosition` is available in addition to `canvasPosition` and `devicePosition`,
and propagation past the topmost component is opt-in via `event.continuePropagation`.

Note that force press requires a pressure-sensitive screen — Apple's 3D Touch, which shipped on the
iPhone 6s through the
[iPhone XS](https://support.apple.com/guide/iphone/aside/iph945ccc462/14.0/ios/14.0), or a small
number of Android devices. On any other device the gesture is never recognized, so these callbacks
never fire. This is unchanged from the old API.


### `onDragCancel` no longer delegates to `onDragEnd`

`DragCallbacks.onDragCancel` used to convert the cancellation into an `onDragEnd` event by default,
which made a cancelled drag look exactly like a completed one. A cancellation means that the gesture
was interrupted (another recognizer won the gesture arena, a second pointer triggered a scale
takeover, a system event, etc.) and it carries no velocity, so components such as drag-to-dismiss
would apply their action even though the drag never finished. This is not a rare event either, since
with `MultiDragScaleDispatcher` every two finger pinch cancels the individual pointer drags.

The default implementation now only resets `isDragged`, which means that `onDragEnd` is no longer
called when a drag is cancelled. If you were relying on the old behavior, override `onDragCancel` and
forward the event yourself with `DragCancelEvent.toDragEnd`:

```dart
// Before
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // This also ran when the drag was cancelled.
    dismiss();
  }
}

// After
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dismiss();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    onDragEnd(event.toDragEnd());
  }
}
```

If a cancelled drag should instead be reverted, put that logic in `onDragCancel` without calling
`onDragEnd`.


### `MultiDragDispatcher` removed

The deprecated `MultiDragDispatcher` and `MultiDragDispatcherKey` aliases have been removed. Use
`MultiDragScaleDispatcher` and `MultiDragScaleDispatcherKey` instead, if you were using them
directly at all (normally you should just use the mixins).

```dart
// Before
game.findByKey(const MultiDragDispatcherKey())
    as MultiDragDispatcher?;

// After
game.findByKey(const MultiDragScaleDispatcherKey())
    as MultiDragScaleDispatcher?;
```


### `Event.handled` removed in favour of `continuePropagation`

Events used to carry two independent booleans: `handled`, which Flame never set nor read, and
`continuePropagation`, which actually controls whether an event keeps traversing down the component
tree. The former has been removed; `continuePropagation` is now the single propagation flag on every
event.

By default, an event stops at the first component that can handle it, so a component that "consumes"
an event does not need to do anything at all — the components below it will not see it:

```dart
// Before
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    if (!event.handled) {
      add(Square(event.localPosition));
    }
  }
}

// After
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    add(Square(event.localPosition));
  }
}
```

If you were using `handled` to let an event reach several components, set
`event.continuePropagation = true` in the components that should pass it along instead.

The equivalent field on the deprecated `*Info` event classes (`TapDownInfo.handled` and friends) has
been removed as well.


### `GameWidget.controlled` renamed to `GameWidget.managed`

The `GameWidget.controlled` constructor has been renamed to `GameWidget.managed`. The behavior is
unchanged; only the name is different.

Replace every usage of `GameWidget.controlled` with `GameWidget.managed`:

```dart
// Before
GameWidget.controlled(
  gameFactory: MyGame.new,
);

// After
GameWidget.managed(
  gameFactory: MyGame.new,
);
```
