## Debug features

Flame provides some features for debugging, these features are enabled when the method `debugMode` from the `BaseGame` class is overridden, and returning `true`. When it's enabled all `PositionComponent`s will be wrapped into a rectangle, and have its position rendered on the screen, so you can visually verify the component boundaries and position.

In addition to the debugMode, you can also ask BaseGame to record the fps, that is enabled by overriding the `recordFps` method to return `true`, by doing so, you can access the current fps by using the method `fps`.

To see a working example of the debugging features, [check this example](/docs/examples/debug).
