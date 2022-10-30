# Debug features


## FlameGame features

Flame provides some debugging features for the `FlameGame` class. These features are enabled when
the `debugMode` property is set to `true` (or overridden to be `true`).
When `debugMode` is enabled, each `PositionComponent` will be rendered with their bounding size, and
have their positions written on the screen. This way, you can visually verify the components
boundaries and positions.

To see a working example of the debugging features of the `FlameGame`, check this
[example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/debug_example.dart).


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

The `FpsTextComponent` is simply a [](../rendering/text.md#textcomponent) that wraps an
[](../rendering/text.md#textcomponent), since you most commonly want to show the current FPS
somewhere when you the [](#fpscomponent) is used.
