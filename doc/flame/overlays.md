# Overlays

Since a Flame game can be wrapped in a widget, it is quite easy to use it alongside other Flutter
widgets in your tree. However, if you want to easily show widgets on top of your Flame game, like
messages, menu screens or something of that nature, you can use the Widgets Overlay API to make
things even easier.

`Game.overlays` enables any Flutter widget to be shown on top of a game instance. This makes it very
easy to create things like a pause menu or an inventory screen for example.

The feature can be used via the `game.overlays.add` and `game.overlays.remove` methods that mark an
overlay to be shown or hidden, respectively, via a `String` argument that identifies the overlay.
After that, you can map each overlay to their corresponding Widget in your `GameWidget` declaration
by providing an `overlayBuilderMap`.

```dart
  // Inside your game:
  final pauseOverlayIdentifier = 'PauseMenu';

  // Marks 'PauseMenu' to be rendered.
  overlays.add(pauseOverlayIdentifier);
  // Marks 'PauseMenu' to not be rendered.
  overlays.remove(pauseOverlayIdentifier);
```

```dart
// On the widget declaration
final game = MyGame();

Widget build(BuildContext context) {
  return GameWidget(
    game: game,
    overlayBuilderMap: {
      'PauseMenu': (BuildContext context, MyGame game) {
        return Text('A pause menu');
      },
    },
  );
}
```

The order of rendering for an overlay is determined by the order of the keys in the
`overlayBuilderMap`.

See an [example of the Overlays feature]
(https://github.com/flame-engine/flame/blob/main/examples/lib/stories/system/overlays_example.dart).
