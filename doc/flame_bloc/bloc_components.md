

# Components


## FlameBlocProvider

FlameBlocProvider is a Component which creates and provides a bloc to its children.  
The bloc will only live while this component is alive.It is used as a dependency injection (DI)
widget so that a single instance of a bloc can be provided to multiple Components within a subtree.

FlameBlocProvider should be used to create new blocs which will be made available to the rest of the
subtree.

```dart
FlameBlocProvider<BlocA, BlocAState>(
  create: () => BlocA(),
  children: [...]
);
```

FlameBlocProvider can be used to provide an existing bloc to a new portion of the Component tree.

```dart
FlameBlocProvider<BlocA, BlocAState>.value(
  value: blocA,
  children: [...],
);
```


## FlameMultiBlocProvider

Similar to FlameBlocProvider, but provides multiples blocs down to the component tree

```dart
FlameMultiBlocProvider(
  providers: [
    FlameBlocProvider<BlocA, BlocAState>(
      create: () => BlocA(),
    ),
    FlameBlocProvider<BlocB, BlocBState>.value(
      create: () => BlocB(),
    ),
    ],
  children: [...],
)
```


## FlameBlocListener

FlameBlocListener is Component which can listen to changes in a Bloc state. It invokes
the `onNewState` in response to state changes in the bloc. For fine-grained control over when
the `onNewState` function is called an optional `listenWhen` can be provided. `listenWhen` takes the
previous bloc state and current bloc state and returns a boolean. If `listenWhen` returns
true, `onNewState` will be called with `state`. If `listenWhen` returns false, `onNewState` will not
be called with `state`.

alternatively you can use `FlameBlocListenable` mixin to listen state changes on Component.

```dart
FlameBlocListener<GameStatsBloc, GameStatsState>(
  listenWhen: (previousState, newState) {
      // return true/false to determine whether or not
      // to call listener with state
  },
  onNewState: (state) {
          // do stuff here based on state
  },
)
```


## FlameBlocListenable

FlameBlocListenable is an alternative to FlameBlocListener to listen state changes.

```dart
class ComponentA extends Component
    with FlameBlocListenable<BlocA, BlocAState> {

  @override
  bool listenWhen(PlayerState previousState, PlayerState newState) {
    // return true/false to determine whether or not
    // to call listener with state
  }

  @override
  void onNewState(PlayerState state) {
    super.onNewState(state);
    // do stuff here based on state
  }
}
```


## FlameBlocReader

FlameBlocReader is mixin that allows you to read the current state of bloc on Component. It is
Useful for components that needs to only read a bloc current state or to trigger an event on it. You
can have only one reader on Component


```dart

class InventoryReader extends Component
    with FlameBlocReader<InventoryCubit, InventoryState> {}

    /// inside game
    
    final component = InventoryReader();
    // reading current state
    var state = component.bloc
```
