# Debug features


## FlameGame features

Flame provides some debugging features for the `FlameGame` class. These features are enabled when
the `debugMode` property is set to `true` (or overridden to be `true`).
When `debugMode` is enabled, each `PositionComponent` will be rendered with their bounding size, and
have their positions written on the screen. This way, you can visually verify the components
boundaries and positions.

Check out this [working example of the debugging features of the `FlameGame`](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/debug_example.dart).


## Devtools extension

If you open the [Flutter DevTools](https://docs.flutter.dev/tools/devtools/overview), you will see a
new tab called "Flame". This tab will show you information about the current game, for example a
visualization of the component tree, the ability to play, pause and step the game, information
about the selected component, and more.

The extension talks to the game through
[service extensions](https://api.flutter.dev/flutter/dart-developer/registerExtension.html) that
Flame registers when a `FlameGame` is created in debug mode. Other tools can call the same service
extensions through the Dart VM Service, for example to take snapshots of a running game.


### Taking snapshots of a running game

Snapshots of a running game can be taken without opening the DevTools. This is useful for scripts
and for AI coding agents that want to see what the game currently looks like, since they can read
the resulting PNG image.

The easiest way to take a snapshot is with the `snapshot` command that comes with the
[flame_test](https://pub.dev/packages/flame_test) package. First run your game in debug mode, and
copy the Dart VM Service URI that `flutter run` prints:

```text
A Dart VM Service on macOS is available at: http://127.0.0.1:50300/abc123=/
```

Then, from your project directory, run:

```shell
dart run flame_test:snapshot --uri http://127.0.0.1:50300/abc123=/ --output snapshot.png
```

This renders the whole game, through the camera and with the game's background color, the same
way that it is currently shown on the screen. Flutter overlays are not part of the game canvas, so
they are not included in the image.

These are the available options:

- `--uri` (`-u`): The Dart VM Service URI of the running game, either the `http` URI that
  `flutter run` prints or the `ws` URI.
- `--output` (`-o`): The file that the PNG image is written to, by default `flame_snapshot.png`.
- `--pixel-ratio` (`-p`): Renders the game in a higher resolution, for example `2` renders an
  800x600 game to a 1600x1200 image.
- `--tree` (`-t`): Prints the component tree together with the id of every component, instead of
  taking a snapshot.
- `--component` (`-c`): The id of a single component to render instead of the whole game.

To take a snapshot of a single component, first list the ids with `--tree`:

```shell
$ dart run flame_test:snapshot --uri http://127.0.0.1:50300/abc123=/ --tree
MyGame (id: 6126309)
  World (id: 729356887)
    Player (id: 220731871)
  CameraComponent (id: 167418721)
    ...
```

Then pass the id with `--component`:

```shell
dart run flame_test:snapshot --uri http://127.0.0.1:50300/abc123=/ --component 220731871
```

The component is rendered together with its children, but without the camera. For a
`PositionComponent`, the image covers the component's bounding rectangle, with its anchor, angle
and scale taken into account. Other components are rendered in a 100x100 image.

To avoid having to copy the URI by hand, for example when an agent starts the game itself, you can
let `flutter run` write it to a file:

```shell
flutter run --vmservice-out-file=vm_service_uri.txt
dart run flame_test:snapshot --uri "$(cat vm_service_uri.txt)"
```


### Service extensions

If you want to build your own tooling, these are the service extensions that can be used for
snapshots. They are only available in debug mode and they are called on the isolate that runs the
game.

- `ext.flame_devtools.getGameSnapshot`: Renders the whole game. It takes an optional `pixelRatio`
  parameter and returns `snapshot` (a base64 encoded PNG image), `width` and `height`.
- `ext.flame_devtools.getComponentSnapshot`: Renders a single component. It takes the `id` of the
  component and returns `snapshot` (a base64 encoded PNG image), which is empty if no component with
  that id was found.
- `ext.flame_devtools.getComponentTree`: Returns the `component_tree`, where every node has an
  `id`, a `name`, the `toString` of the component and its `children`.

The id of a component is its `hashCode`. If you have multiple games in your app, only the last one
created is connected, see `DevToolsService.initWithGame` to change it.


## FPS

The FPS reported from Flame might be a bit lower than what is reported from for example the Flutter
DevTools, depending on which platform you are targeting. The source of truth for how many FPS your
game is running in should be the FPS that we are reporting, since that is what our game loop is
bound by.


### FpsComponent

The `FpsComponent` can be added to anywhere in the component tree and will keep track of how many
FPS that the game is currently rendering in. If you want to display this as text in the game, use
the [](#fpstextcomponent).


### FpsTextComponent

The `FpsTextComponent` is simply a [TextComponent] that wraps an `FpsComponent`, since you most
commonly want to show the current FPS somewhere when the `FpsComponent` is used.


[TextComponent]: ../rendering/text_rendering.md#textcomponent


### ChildCounterComponent

`ChildCounterComponent` is a component that renders the number of children of
type `T` from a component (`target`) every second.
So for example, the following will render the number of `SpriteAnimationComponent` that are
children of the game `world`:

```dart
add(
  ChildCounterComponent<SpriteAnimationComponent>(
    target: world,
  ),
);
```


### TimeTrackComponent

This component allows developers to track time spent inside their code. This can be useful for
performance debugging time spent in certain parts of the code.

To use it, add it to your game somewhere (since this is a debug feature, we advise to only add the
component in a debug build/flavor):

```dart
add(TimeTrackComponent());
```

Then in the code section that you want to track time, do the following:

```dart
void update(double dt) {
  TimeTrackComponent.start('MyComponent.update');
  // ...
  TimeTrackComponent.end('MyComponent.update');
}
```

With the calls above, the added `TimeTrackComponent` will render the elapsed time in
microseconds.
