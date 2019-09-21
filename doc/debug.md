## Debug features

Flame provides some features for debugging, these features are enabled when the method `debugMode` from the `BaseGame` class is overriden, and returning `true`. When enabled all `PositionComponent`s will have be wrapped into a rectangle, and have its position rendered on the screen, so you can visually verify the component bondaries and position.

BaseGame will also start record the fps when in debug mode, you can access the current fps by using the method `fps`.

To see an working example of the debugging features, [check this example](/doc/examples/debug).
