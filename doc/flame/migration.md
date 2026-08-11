# Migration Guides

This section describes the breaking changes that you need to be aware of when upgrading between
major versions of Flame, together with the steps required to migrate your code.


## Migrating from v1.38.0 to v2.0.0


### `ForcePressDetector` removed

The `ForcePressDetector` mixin and its `ForcePressInfo` event class have been removed, with no
replacement.

It was a niche API, only available on some older Apple's 3D Touch devices; the iPhone XS and XS Max
(2018) were the last models to include it (see Apple's
[Models with 3D Touch](https://support.apple.com/guide/iphone/aside/iph945ccc462/14.0/ios/14.0),
a list that Apple even stopped carrying forward after the iOS 14 guide). Every iPhone since,
starting with the XR, uses Haptic Touch, which responds to how long a press lasts rather than how
hard it is, and so never produces these callbacks. Only a handful of Android devices ever
supported it, and some of those (such as the Pixel 2 and 3) have faux pressure sensors that never
fired the callbacks anyway.

Combined with force press being the last gesture without an equivalent on the component-level event
system, maintaining it was no longer worth the surface area.

If you do still target a 3D Touch device, the gesture remains fully available from Flutter: wrap
your `GameWidget` in a
[`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html) and use its
`onForcePressStart`, `onForcePressPeak`, `onForcePressUpdate` and `onForcePressEnd` callbacks
directly.


### Deprecated tap and long press game detectors removed

The game-level detector mixins that were deprecated in v1.38.0 have now been removed, together with
the event classes that only they used:

| Removed | Use instead |
| --- | --- |
| `TapDetector` | `TapCallbacks` |
| `SecondaryTapDetector` | `SecondaryTapCallbacks` |
| `TertiaryTapDetector` | `TertiaryTapCallbacks` |
| `DoubleTapDetector` | `DoubleTapCallbacks` |
| `LongPressDetector` | `LongPressCallbacks` |
| `LongPressStartInfo` | `LongPressStartEvent` |
| `LongPressMoveUpdateInfo` | `LongPressMoveUpdateEvent` |
| `LongPressEndInfo` | `LongPressEndEvent` |

The replacements are mixed into a component rather than into the game, and each callback takes a
single event object:

```dart
// Before
class MyGame extends FlameGame with TapDetector {
  @override
  void onTapDown(TapDownInfo info) {
    final position = info.eventPosition.widget;
  }
}

// After
class MyComponent extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
  }
}
```

Note that a component only receives events that occur on top of it, as determined by
`containsLocalPoint()`, whereas the old game-level detectors received every event on the game
surface. To keep the old whole-screen behavior, add the mixin to your `FlameGame` subclass directly
— `FlameGame` is itself a `Component`.

See [Tap Events](inputs/tap_events.md) and [Long Press Events](inputs/long_press_events.md) for the
full replacement APIs.


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


### `Game.paused` renamed to `Game.isPaused`

The `paused` getter and setter on `Game` have been renamed to `isPaused`, to be consistent with the
other boolean properties in Flame. The behavior is unchanged; only the name is different.

Replace every usage of `game.paused` with `game.isPaused`:

```dart
// Before
if (game.paused) {
  game.paused = false;
}

// After
if (game.isPaused) {
  game.isPaused = false;
}
```
