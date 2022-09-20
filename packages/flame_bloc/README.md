# Flame Bloc 🔥🧱

`flame_bloc` offers a simple and natural (as in similar to `flutter_bloc`) way to use blocs and
cubits inside a `FlameGame`.

For a migration guide from the previous API to the current one,
[check this article](https://verygood.ventures/blog/flame-bloc-new-api).


## How to use

Lets assume we have a bloc that handles player inventory, first we need to make it available to our
components.

We can do that by using `FlameBlocProvider` component:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await add(
      FlameBlocProvider<PlayerInventoryBloc, PlayerInventoryState>(
        create: () => PlayerInventoryBloc(),
        children: [
          Player(),
          // ...
        ],
      ),
    );
  }
}
```

With the above changes, the `Player` component will now have access to our bloc.

If more than one bloc needs to be provided, `FlameMultiBlocProvider` can be used in a similar fashion:

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await add(
      FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<PlayerInventoryBloc, PlayerInventoryState>(
            create: () => PlayerInventoryBloc(),
          ),
          FlameBlocProvider<PlayerStatsBloc, PlayerStatsState>(
            create: () => PlayerStatsBloc(),
          ),
        ],
        children: [
          Player(),
          // ...
        ],
      ),
    );
  }
}
```

Listening to states changes at the component level can be done with two approaches:

By using `FlameBlocListener` component:

```dart
class Player extends PositionComponent {
  @override
  Future<void> onLoad() async {
    await add(
      FlameBlocListener<PlayerInventoryBloc, PlayerInventoryState>(
        listener: (state) {
          updateGear(state);
        },
      ),
    );
  }
}
```

Or by using `FlameBlocListenable` mixin:

```dart
class Player extends PositionComponent
  with FlameBlocListenable<PlayerInventoryBloc, PlayerInventoryState> {

  @override
  void onNewState(state) {
    updateGear(state);
  }
}
```

If all your component need is to simply access a bloc, the `FlameBlocReader` mixin can be applied
to a component:


```dart
class Player extends PositionComponent
  with FlameBlocReader<PlayerStatsBloc, PlayerStatsState> {

  void takeHit() {
    bloc.add(const PlayerDamaged());
  }
}
```

Note that one limitation of the mixin is that it can access only a single bloc.

For a full example, check the [example folder](./example)
