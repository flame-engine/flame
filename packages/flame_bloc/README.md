# Flame Bloc 🔥🧱

`flame_bloc` adds easy access to blocs/cubits that are available on the widget tree to your Flame
game and makes it possible for Flame components to listen to state changes to those blocs/cubits.

## How to use

Lets assume we have a bloc that handles player inventory and it is available on the widget tree via
a `BlocProvider` like this:

```dart
BlocProvider<ExampleGame>(
  create: (_) => InventoryBloc(),
  child: GameWidget(game: ExampleGame()),
)
```

To access the bloc from inside your game, the `read` method can be used.

```dart
class ExampleGame example FlameBlocGame {
  void selectWeapon() {
    read<InventoryBloc>.add(WeaponSelected('axe'));
  }
}
```

To have your components listen to state change, the `BlocComponent` mixin can be used.


```dart
class PlayerComponent with BlocComponent<InventoryBloc, InventoryState> {

  // onNewState can be overriden to so the component
  // can be notified on state changes
  @override
  void onNewState(InventoryState state) {
    print(state.weapon);
  }

  @override
  void update(double dt) {
    // the `state` getter can also be used to have
    // direct access to the current state
    print(state.weapon);
  }
}
```

For a full example, check the [example folder](./example)
