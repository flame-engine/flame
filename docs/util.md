# Util

Some stuff just doesn't fit anywhere else.

## Position

Throughout the variety of modules needed to build a game, Dart and Flutter have a few different classes to handle the concept of a 2D double point; specially common in the APIs are math.Point and ui.Offset.

The Position class is an utility class that helps by allowing easy conversions to and from these type.

It also differs from the default implementations provided (math.Point and ui.Offset) as it's mutable and offers some useful methods for manipulation.

## Text

In order to render text to the Canvas, you can use the utility method `text`:

```dart
    var txt = Flame.util.text('Once upon a time...', fontSize: 12.0, color: 0xFF00FF00);
    txt.paint(canvas, new Offset(10.0, 10.0)); // position
```

The string to be rendered is mandatory, and then there is a myriad of parameters with default values:

* fontSize : font size, in pts (default `24.0`)
* color : the color, as a `ui.Color` (see below, default black)
* fontFamily : a commonly available font, like Arial (default), or a custom font added in your pubspec (see [here](https://flutter.io/custom-fonts/) how to do it)
* textAlign : `TextAlign` enum, can be `left`, `right`, `center`, `justify` (among others, default `left`)
* textDirection : `TextDirection` enum, can be `ltr` (default, left to right, probably you want this one) or `rtl` (right to left, use only if using fonts from different languages)

To create a Color object, just pass in the color as an integer in the ARGB format.

You can use Dart's hexadecimal notation to make it really easy; for instance: `0xFF00FF00` is fully opaque green (the 'mask' would be `0xAARRGGBB`).

There is a color enum to make it easy to use common colors; it is in the material flutter package:

```dart
    import 'package:flutter/material.dart' as material;

    Color color = material.Colors.black;
```

## Util Class

This class, accessible via `Flame.util`, has some sparse functions that are independent and good to have. They are:

 * fullScreen : call once in the main method, makes your app full screen (no top nor bottom bars)
 * addGestureRecognizer discussed [here](#Input)
 * text : discussed [here](#Text)
 * initialDimensions : returns a Future with the dimension (Size) of the screen. This has to be done in a hacky way because of the reasons described in the code. If you are using `BaseGame`, you probably won't need to use these, as very `Component` will receive this information
 * drawWhere : a very simple function that manually applies an offset to a canvas, render stuff given via a function and then reset the canvas, without using the canvas built-in save/restore functionality. This might be useful because `BaseGame` uses the state of the canvas, and you should not mess with it.