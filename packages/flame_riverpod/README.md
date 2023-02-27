# flame_riverpod

Helpers for using Riverpod in conjunction with Flame - to share state from
the game into other parts of your application, or from other parts of your
application into your game.

## Getting started

Check out the example package to see a FlameGame with a custom Component being updated alongside a comparable Flutter 
widget. Both depend on a StreamProvider.

## Usage
Your widget that extends `FlameGame` should use the `HasComponentRef` mixin, and accept a WidgetRef inside its 
constructor. This is mapped to a `ComponentRef`, which exposes a subset of the functionality users of Riverpod will 
be familiar with - this is because Components are *not* Widgets!

In Riverpod with Flame, you should use `listen` to subscribe to updates from a provider. Alternatively, you could use 
`ref.read` as you would elsewhere in Flutter.

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

  /// [onMount] should be used over [onLoad] to initialise subscriptions, 
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
