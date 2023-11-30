# flame_riverpod

[Riverpod](https://pub.dev/packages/flutter_riverpod) is a reactive caching and data-binding
framework for Dart & Flutter.

In `flutter_riverpod`, widgets can be configured to rebuild when the state
of a provider changes.

When using Flame, we are interacting with components, which are *not* Widgets.

`flame_riverpod` provides the `RiverpodAwareGameWidget`, `RiverpodGameMixin`, and
`RiverpodComponentMixin` to facilitate managing state from Providers in your Flame Game.


## Usage

You should use the `RiverpodAwareGameWidget` as your Flame `GameWidget`, the `RiverpodGameMixin`
mixin on your game that extends `FlameGame`, and the `RiverpodComponentMixin` on any components
interacting with Riverpod providers.

The full range of operations defined in Riverpod's `WidgetRef` definition are accessible from
components.

Subscriptions to a provider are managed in accordance with the lifecycle
of a Flame Component: initialization occurs when a Component is mounted, and disposal
occurs when a Component is removed. By default, the `RiverpodAwareGameWidget` is rebuilt when
Riverpod-aware (i.e. using the `RiverpodComponentMixin`) components are mounted and when they are
removed.

```dart

/// An excerpt from the Example. Check it out!
class RefExampleGame extends FlameGame with RiverpodGameMixin {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(TextComponent(text: 'Flame'));
    add(RiverpodAwareTextComponent());
  }
}

class RiverpodAwareTextComponent extends PositionComponent
    with RiverpodComponentMixin {
  late TextComponent textComponent;
  int currentValue = 0;

  /// [onMount] should be used over [onLoad] to initialize subscriptions,
  /// cancellation is handled for the user inside [onRemove],
  /// which is only called if the [Component] was mounted.
  /// 
  /// [RiverpodComponentMixin.addToGameWidgetBuild] **must** be invoked in 
  /// your Component **before** [RiverpodComponentMixin.onMount] in order to 
  /// have the provided function invoked on 
  /// [RiverpodAwareGameWidgetState.build].
  /// 
  /// From `flame_riverpod` 5.0.0, [WidgetRef.watch], is also accessible from 
  /// components.
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


## Credits

[Mark Videon](https://markvideon.dev) for the initial groundwork and implementation.
