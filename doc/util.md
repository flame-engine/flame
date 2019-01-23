# Util

Some stuff just doesn't fit anywhere else.

## Position

Throughout the variety of modules needed to build a game, Dart and Flutter have a few different classes to handle the concept of a 2D double point; specially common in the APIs are math.Point and ui.Offset.

The Position class is an utility class that helps by allowing easy conversions to and from these type.

It also differs from the default implementations provided (math.Point and ui.Offset) as it's mutable and offers some useful methods for manipulation.

## Util Class

This class, accessible via `Flame.util`, has some sparse functions that are independent and good to have. They are:

 * fullScreen : call once in the main method, makes your app full screen (no top nor bottom bars)
 * addGestureRecognizer discussed [here](#Input)
 * text : discussed [here](#Text)
 * initialDimensions : returns a Future with the dimension (Size) of the screen. This has to be done in a hacky way because of the reasons described in the code. If you are using `BaseGame`, you probably won't need to use these, as very `Component` will receive this information
 * drawWhere : a very simple function that manually applies an offset to a canvas, render stuff given via a function and then reset the canvas, without using the canvas built-in save/restore functionality. This might be useful because `BaseGame` uses the state of the canvas, and you should not mess with it.
