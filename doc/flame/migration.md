# Migration Guides

This section describes the breaking changes that you need to be aware of when upgrading between
major versions of Flame, together with the steps required to migrate your code.


## Migrating from v1.38.0 to v2.0.0


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


### `children` is now a `ComponentList` instead of an `OrderedSet`

The `ordered_set` package is no longer used; children live in a Flame-owned `ComponentList` that
is significantly faster. The iterable surface, `query<T>()`, `register<T>()`, and `reversed()` are
unchanged, so most code compiles as is. If you imported `package:ordered_set` types to annotate
variables, use `ComponentList` (from `package:flame/components.dart`) instead:

```dart
// Before
import 'package:ordered_set/ordered_set.dart';
OrderedSet<Component> children = component.children;

// After
ComponentList children = component.children;
```

Two behavioral notes:

- `query<T>()` results are now always in priority order.
- Mutating `children` while iterating it now tolerates removals and appends at the end; only
  position-shifting operations (a mid-list insertion, a reorder, or tombstone compaction) throw
  `ConcurrentModificationError`.


### `Component.childrenFactory` is removed

The global children-container factory is gone. Override `createComponentList()` on the component
instead. The constructor accepts an optional `Comparator<Component>` that replaces priority
ordering for that parent, which gives custom orderings such as y-sort a supported home:

```dart
// Before
Component.childrenFactory = () => OrderedSet.mapping<num, Component>((c) => c.priority);

// After
class YSortedWorld extends World {
  @override
  ComponentList createComponentList() {
    return ComponentList(
      comparator: (a, b) => (a as PositionComponent)
          .position.y
          .compareTo((b as PositionComponent).position.y),
    );
  }
}
```


### `Component.updateTree` is non-virtual

The update pass runs over a flattened traversal list owned by the game, so `updateTree` can no
longer be overridden. If you overrode it, implement the `CustomTraversal` marker interface and
override `Component.updateSubtree` instead; call `super.updateSubtree(dt)` to run the standard
traversal:

```dart
// Before
class SlowMotionArea extends Component {
  @override
  void updateTree(double dt) => super.updateTree(dt / 2);
}

// After
class SlowMotionArea extends Component implements CustomTraversal {
  @override
  void updateSubtree(double dt) => super.updateSubtree(dt / 2);
}
```

`HasTimeScale` usage is unchanged (`with HasTimeScale` still works; the mixin carries the marker
itself). To simply stop updating a subtree, the new `updatePaused` flag replaces the common
gating override: `component.updatePaused = true` pauses the update pass for the component and its
whole subtree while rendering, event handling, and lifecycle processing continue.


### `Route.stopTime()` no longer zeroes `timeScale`

A stopped route is now paused through `updatePaused` instead of `timeScale = 0`:

- While stopped, `timeScale` keeps its previous value, so a slow-motion factor survives a
  stop/resume cycle.
- Assigning a new `timeScale` no longer resumes a stopped route; use `resumeTime()` or
  `updatePaused = false`.
- Pending lifecycle events (adding or removing components) on a stopped route now still complete.
