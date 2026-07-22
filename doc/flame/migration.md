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
