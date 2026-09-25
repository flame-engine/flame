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
extensions through the Dart VM Service. The [Flame CLI](cli.md) uses them to take snapshots of a
running game from the terminal, which is also useful for scripts and AI coding agents.


### Service extensions

If you want to build your own tooling, these are the service extensions that the DevTools
extension and the CLI use. They are only available in debug mode and they are called on the
isolate that runs the game. Every `id` parameter is the `hashCode` of a component.

- `ext.flame_devtools.getGameSnapshot`: Renders the whole game. It takes an optional `pixelRatio`
  parameter and returns `snapshot` (a base64 encoded PNG image), `width` and `height`.
- `ext.flame_devtools.getComponentSnapshot`: Renders a single component. It takes the `id` of the
  component and an optional `pixelRatio` parameter, and returns `snapshot` (a base64 encoded PNG
  image). It responds with an invalid parameters error if no component with that id was found.
- `ext.flame_devtools.getComponentTree`: Returns the `component_tree`, where every node has an
  `id`, a `name`, the `toString` of the component, its `attributes` and its `children`. The
  attributes are the `priority` of the component, and for a `PositionComponent` also its
  `position`, `size`, `angle`, `scale` and `anchor`.
- `ext.flame_devtools.getComponentInfo`: Returns the same fields as a tree node for the component
  with the given `id`, without the children, and additionally the id of its `parent`, its
  `childCount` and its `debugMode`.
- `ext.flame_devtools.getPositionComponentAttributes` and
  `ext.flame_devtools.setPositionComponentAttributes`: Read and change the attributes of a
  `PositionComponent`. Setting takes the `id`, an `attribute` (`x`, `y`, `width`, `height`,
  `angle`, `scaleX`, `scaleY`, `anchor` or `priority`) and the `value` as a string. The
  `priority` can be set on any component.
- `ext.flame_devtools.getPaused`, `ext.flame_devtools.setPaused` and `ext.flame_devtools.step`:
  Read and change whether the game loop is paused, and step a paused game by `step_time` seconds.
- `ext.flame_devtools.getDebugMode` and `ext.flame_devtools.setDebugMode`: Read and change the
  `debug_mode` of the whole game, or of a single component when an `id` is given.
- `ext.flame_devtools.getOverlays`: Returns the registered `overlays` and the `active` ones.
- `ext.flame_devtools.setOverlay`: Shows or hides the `overlay` with the given name depending on
  the `active` parameter.
- `ext.flame_devtools.navigateToOverlay`: Shows the `overlay` with the given name and hides all
  the others.

If you have multiple games in your app, only the last one created is connected, see
`DevToolsService.initWithGame` to change it.


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
