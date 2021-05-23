# Basic: Sprites, Animations and Gestures

This tutorial will introduce you to:

 - `Sprite`: Sprites are how we draw images, or portions of an image in Flame.
 - `SpriteAnimation`: SpriteAnimations are animations composed from sprites, where each sprite represents a frame.
 - Gesture input: the most basic input for your game, the tap detector.

All the code of this tutorial code can be found [here](./code).

By the end of this tutorial, you will have built a simple game which renders a button that, when pressed, makes a small vampire robot run. It will look like this:

![Preview](./media/preview.gif)

## Sprite

Before starting coding our game, it is important to understand what sprites are and what they are used for.

Sprites are images, or a portion of an image, loaded into the memory, and can then be used to render graphics on your game canvas.

Sprites can be (and usually are) bundled into single images, called Sprite Sheets. That is a very useful technique as it lowers the amount of I/O operations needed to load the game assets because it is faster to load 1 image of 10 KB than to load 10 images of 1 KB each (among other advantages).

For example, on this tutorial, we will have a button that makes our robot run. This button needs two sprites, for the unpressed and pressed states. We can have the following image containing both, this technique is often called sprite sheet.

![Sprite example](code/assets/images/buttons.png)


## Animations

Animation is what gives 2D games life. Flame provides a handy class called `SpriteAnimation` which lets you create an animation out of a list of sprites representing each frame, in sequence. Animations are usually bundled in a single Sprite Sheet, like this one:

![Animation example](code/assets/images/robot.png)

Flame provides a way for easily turning that Sprite Sheet into an animation (we will see how in a few moments).

## Hands on

To get started, let's get a Flame `Game` instance running with a structure similar to our [first tutorial](https://github.com/flame-engine/flame/tree/main/tutorials/1_basic_square#building-your-first-game) (if you haven't yet, you can follow it to better understand this initial setup).

```dart
void main() {
  final myGame = MyGame();
  runApp(GameWidget(game: myGame));
}

class MyGame extends Game {

  @override
  void update(double dt) {
  }

  @override
  void render(Canvas canvas) {
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);
}
```

Great! This will just gets us a plain, almost black screen. Now lets add our running robot:

```dart
class MyGame extends Game {
  late SpriteAnimation runningRobot;

  // Vector2 is a class from `package:vector_math/vector_math_64.dart` and is widely used
  // in Flame to represent vectors. Here we need two vectors, one to define where we are
  // going to draw our robot and another one to define its size
  final robotPosition = Vector2(240, 50);
  final robotSize = Vector2(48, 60);

  // Now, on the `onLoad` method, we need to load our animation. To do that we can use the
  // `loadSpriteAnimation` method, which is present on our game class.
  @override
  Future<void> onLoad() async {
    runningRobot = await loadSpriteAnimation(
      'robot.png',
      // `SpriteAnimationData` is a class used to tell Flame how the animation Sprite Sheet
      // is organized. In this case we are describing that our frames are laid out in a horizontal
      // sequence on the image, that there are 8 frames, that each frame is a sprite of 16x18 pixels,
      // and, finally, that each frame should appear for 0.1 seconds when the animation is running.
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(16, 18),
        stepTime: 0.1,
      ),
    );
  }

  @override
  void update(double dt) {
    // Here we just need to "hook" our animation into the game loop update method so the current frame is updated with the specified frequency
    runningRobot.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Since an animation is basically a list of sprites, to render it, we just need to get its
    // current sprite and render it on our canvas. Which frame is the current sprite is updated on the `update` method.
    runningRobot
        .getSprite()
        .render(canvas, position: robotPosition, size: robotSize);
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);
}
```

When running the game now, you should see our vampire robot running endlessly on the screen.

For the next step, let's implement our on/off button and render it on the screen.

The first thing we need to do is to add a couple of variables needed to reference our button:

```dart
  // One sprite for each button state
  late Sprite pressedButton;
  late Sprite unpressedButton;
  // Just like our robot needs its position and size, here we create two
  // variables for the button as well
  final buttonPosition = Vector2(200, 120);
  final buttonSize = Vector2(120, 30);
  // Simple boolean variable to tell if the button is pressed or not
  bool isPressed = false;
```

Next, we can load our two sprites:

```dart
  @override
  Future<void> onLoad() async {
    // runningRobot loading omitted

    // Just like we have a `loadSpriteAnimation` function, here we can use
    // `loadSprite`. To use it, we just need to inform the asset's path
    // and the position and size defining the section of the whole image
    // that we want. If we wanted to have a sprite with the full image, `srcPosition`
    // and `srcSize` could just be omitted
    unpressedButton = await loadSprite(
      'buttons.png',
      // `srcPosition` and `srcSize` here tells `loadSprite` that we want
      // just a rect (starting at (0, 0) with the dimensions (60, 20)) of the image
      // which gives us only the first button
      srcPosition: Vector2.zero(), // this is zero by default
      srcSize: Vector2(60, 20),
    );

    pressedButton = await loadSprite(
      'buttons.png',
      // Same thing here, but now a rect starting at (0, 20)
      // which gives us only the second button
      srcPosition: Vector2(0, 20),
      srcSize: Vector2(60, 20),
    );
  }
```

Finally, we just render it on the game `render` function:

```dart
  @override
  void render(Canvas canvas) {
    // Running robot render omited

    final button = isPressed ? pressedButton : unpressedButton;
    button.render(canvas, position: buttonPosition, size: buttonSize);
  }
```

You now should see the button on the screen, but right now, it is pretty much useless as it has no action at all.

So, to change that, we will now add some interactivity to our game and make the button tapable/clickable.

Flame provides several input handlers, which you can check with more in depth on [our docs](https://github.com/flame-engine/flame/blob/main/doc/input.md). For this tutorial, we will be using the `TapDetector` which enables us to detect taps on the screen, as well as mouse click when running on web or desktop.

All Flame input detectors are mixins which can be added to your game, enabling you to override listener methods related to that detector. For the `TapDetector`, we will need to override three methods:

 - `onTapDown`: Called when touch/click has started, i.e., the user just touced the screen or clicked the mouse button.
 - `onTapUp`: Called when the touch/click has stop occurring because the event was released, i.e., the user lifted the finger from the screen or released the mouse button.
 - `onTapCancel`: Called when the event was cancelled. This can happen for several reasons; one of the most common is when the event has changed into another type, for example the user started to move the finger/mouse and the touch event now turned into a pan/drag. Usually, we can just treat this event as being the same as `onTapUp`.

Now that we have a better understanding of `TapDetector` and the events that we will need to handle, let's implement it on the game:

```dart
// We need to add our `TapDetector` mixin here
class MyGame extends Game with TapDetector {
  // Variables declaration, onLoad and render methods omited...

  @override
  void onTapDown(TapDownInfo event) {
    // On tap down we need to check if the event ocurred on the
    // button area. There are several ways of doing it, for this
    // tutorial we do that by transforming ours position and size
    // vectors into a dart:ui Rect by using the `&` operator, and
    // with that rect we can use its `contains` method which checks
    // if a point (Offset) is inside that rect
    final buttonArea = buttonPosition & buttonSize;

    isPressed = buttonArea.contains(event.eventPosition.game.toOffset());
  }

  // On both tap up and tap cancel we just set the isPressed
  // variable to false
  @override
  void onTapUp(TapUpInfo event) {
    isPressed = false;
  }

  @override
  void onTapCancel() {
    isPressed = false;
  }

  // Finally, we just modify our update method so the animation is
  // updated only if the button is pressed
  @override
  void update(double dt) {
    if (isPressed) {
      runningRobot.update(dt);
    }
  }
}
```

If we run our game again, we should be able to see the complete example, with our on/off button for our little vampire robot.

And with that, we finished this tutorial. Now, with an understanding of sprites, animations and gestures, we can start on building more interactive and beautiful games.
