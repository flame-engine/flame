# flame_riverpod

Riverpod is a reactive caching and data-binding framework for Dart & Flutter. 

In `flutter_riverpod`, widgets can be configured to rebuild when the state 
of a provider changes.

When using Flame, we are interacting with components, which are *not* Widgets.

`flame_riverpod` provides the `ComponentRef` and `HasComponentRef` to 
facilitate managing state from Providers in your Flame Game.

## Usage
Your Widget that extends `FlameGame` should use the HasComponentRef mixin, 
and accept a WidgetRef inside its constructor, and should be wrapped in a 
ConsumerStatefulWidget, as per the example. 

The `listen` method can be used within any Component that uses the 
HasComponentMixin to subscribe to updates from a provider. 

Alternatively, you could use `ref.read` as you would elsewhere when consuming `flutter_riverpod`.

Subscriptions to a provider are managed in accordance with the lifecycle 
of a Flame Component: initialization occurs when a Component is mounted, and disposal 
occurs when a Component is removed.

```dart
/// An excerpt from the Example. Check it out!
class RefExampleGame extends FlameGame with HasComponentRef {
  RefExampleGame(WidgetRef ref) {
    HasComponentRef.widgetRef = ref;
  }

  @override
  onLoad() async {
    await super.onLoad();
    add(TextComponent(text: 'Flame'));
    add(RiverpodAwareTextComponent());
  }
}

class RiverpodAwareTextComponent extends PositionComponent
    with HasComponentRef {

  late TextComponent textComponent;
  int currentValue = 0;

  /// [onMount] should be used over [onLoad] to initialize subscriptions, 
  /// cancellation is handled for the user inside [onRemove], 
  /// which is only called if the [Component] was mounted.
  @override
  void onMount() {
    super.onMount();
    add(textComponent = TextComponent(position: position + Vector2(0, 27)));

    // "Watch" a provider using [listen] from the [HasComponentRef] mixin. 
    // Watch is not exposed directly as this would rebuild the ancestor that 
    // exposes the [WidgetRef] unnecessarily. 
    listen(countingStreamProvider, (p0, p1) {
      if (p1.hasValue) {
        currentValue = p1.value!;
        textComponent.text = '$currentValue';
      }
    });
  }
}

```
# Credits

[Mark Videon](https://markvideon.dev) for the initial groundwork and implementation.