# Migration Guides

This section describes the breaking changes that you need to be aware of when upgrading between
major versions of Flame, together with the steps required to migrate your code.


## Migrating from v1.38.0 to v2.0.0


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
