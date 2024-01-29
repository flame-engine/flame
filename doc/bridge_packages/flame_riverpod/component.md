# Component


## ComponentRef

`ComponentRef` exposes Riverpod functionality to individual `Component`s, and is comparable to
`flutter_riverpod`'s `WidgetRef`.


## RiverpodComponentMixin

`RiverpodComponentMixin` manages the lifecycle of listeners on behalf of individual `Component`s.

`Component`s using this mixin must use `addToGameWidgetBuild` in their `onMount` method to add
listeners (e.g. `ref.watch` or `ref.listen`) *prior to* calling `super.onMount`, which manages the
staged listeners and disposes of them on the user's behalf inside `onRemove`.

```dart

class RiverpodAwareTextComponent extends PositionComponent
    with RiverpodComponentMixin {
  late TextComponent textComponent;
  int currentValue = 0;

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      ref.listen(countingStreamProvider, (p0, p1) {
        if (p1.hasValue) {
          currentValue = p1.value!;
          textComponent.text = '$currentValue';
        }
      });
    });
    super.onMount();
    add(textComponent = TextComponent(position: position + Vector2(0, 27)));
  }
}

```


## RiverpodGameMixin

`RiverpodGameMixin` provides listeners from all components to the build method of the
`RiverpodAwareGameWidget`.
The `addToGameWidgetBuild` method is available in the `RiverpodGameMixin` as well, enabling you to access `ComponentRef` methods directly in your Game class.
