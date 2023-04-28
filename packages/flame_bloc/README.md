<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Offers a simple and natural way to use <a href="https://github.com/felangel/bloc">flutter_bloc</a> inside <a href="https://github.com/flame-engine/flame">Flame</a>.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_bloc" ><img src="https://img.shields.io/pub/v/flame_bloc.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
# flame_bloc 🔥🧱

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
