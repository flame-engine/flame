# Camera and Viewport

When rendering on Flutter, the regular coordinate space used are logical pixels. That means one
pixel for Flutter is already not necessarily one real pixel on the device, because of the [device's
pixel ratio](https://api.flutter.dev/flutter/widgets/MediaQueryData/devicePixelRatio.html). When it
gets to the Flame level, we always consider the most fundamental level to be logical pixels, so all
the device specific complexity is abstracted away.

However, that still leaves you with arbitrarily shaped and sized screens. And it's very likely that
your game has some sort of game world with an intrinsic coordinate system that does not map to
screen coordinates. Flame adds two distinct concepts to help transform coordinate spaces. For the
former, we have the Viewport class. And for the later, we have the Camera class.

## Viewport

The Viewport is an attempt to unify multiple screen (or, rather, game widget) sizes into a single
configuration for your game by translating and resizing the canvas.

The `Viewport` interface has multiple implementations and can be used from scratch on your `Game`
or, if you are using `FlameGame` instead, it's already built-in (with a default no-op viewport).

These are the viewports available to pick from (or you can implement the interface yourself to suit
your needs):

 * `DefaultViewport`: this is the no-op viewport that is associated by default with any `FlameGame`.
 * `FixedResolutionViewport`: this viewport transforms your Canvas so that, from the game
   perspective, the dimensions are always set to a fixed pre-defined value. This means it will scale
   the game as much as possible and add black bars if needed.

When using `FlameGame`, the operations performed by the viewport are done automatically to every
render operation, and the `size` property in the game, instead of the logical widget size, becomes
the size as seen through the viewport together with the zoom of the camera. If for some reason you
need to access the original real logical pixel size, you can use `canvasSize`. For a more in depth
description on what each `Viewport` does and how it operates, check the documentation on its class.

## Camera

Unlike the `Viewport`, the `Camera` is a more dynamic `Canvas` transformation that is normally
dependent on:

 * World coordinates that do not match screen coordinates 1:1.
 * Centering or following the player around the game world (if the world is bigger than the screen).
 * User controlled zooming in and out.

There is only one Camera implementation but it allows for many different configurations. Again, you
can use it standalone on your `Game` but it's already included and wired into `FlameGame`.

One important thing to note about the Camera is that since (unlike the Viewport) it's intended to be
dynamic, most camera movements won't immediately happen. Instead, the camera has a configurable
speed and is updated on the game loop. If you want to immediately move your camera (like on your
first camera setup at game start) you can use the `snap` function. Calling snap during the game can
lead to jarring or unnatural camera movements though, so avoid that unless desired (say for a map
transition, for example). Carefully check the docs for each method for more details about how it
affects the camera movement.

Another important note is that the camera is applied after the viewport, and only to non-HUD
components. So screen size here is considering the effective size after Viewport transformations.

There are two types of transformations that the Camera can apply to the Canvas. The first and most
complex one is translation. That can be applied by several factors:

 * nothing: by default the camera won't apply any transformation, so it's optional to use it.
 * relative offset: you can configure this to decide "where the center of the camera should be on
   the screen". By default it's the top left corner, meaning that the centered coordinate or object
   will always be on the top left corner of the screen. You can smoothly change the relative offset
   during gameplay (that can be used to apply a dialogue or item pickup temporary camera transition
   for example).
 * moveTo: if you want to ad-hoc move your camera you can use this method; it will smoothly
   transition the camera to a new position, ignoring follows but respecting relative offset and
   world bounds. This can be reset by `resetMovement` if used in conjunction to follow so that the
   followed object starts being considered again.
 * follow: you can use this method so that your camera continuously "follow" an object (for example,
   a `PositionComponent`). This is not smooth because the movement of the followed object itself is
   assumed to already be smooth (i.e. if your character teleport the camera will also immediately
   teleport).
 * world bounds: when using follow, you can optionally define the bounds of the world. If that is
   done, the camera will stop following/moving so that out-of-bounds areas are not shown (as long as
   the world is bigger than the screen).

Finally the second transformation that the camera applies is scaling. That allows for dynamic
zooming, and it's controlled by the `zoom` field. There is no zoom speed, that must be controlled by
you when changing. The `zoom` variable is immediately applied.

When dealing with input events, it is imperative to convert screen coordinates to world coordinates
(or, for some reasons, you might want to do the reverse). The Camera provides two functions,
`screenToWorld` and `worldToScreen` to easily convert between these coordinate spaces.

### Using the camera with the Game class

If you are not using `FlameGame`, but instead are using the `Game` class, then you need to manage
calling certain camera methods yourself. Let's say we have the following game structure, and we 
want to add the camera functionality:

```dart
class YourGame extends Game {
  Camera? camera;

  Future<void> onLoad() async {}

  void render(Canvas canvas) {}

  void update(double dt) {}
}
```

We first create a new camera instance on load and assign our game as the reference:

```dart
  // ...
  
  Future<void> onLoad() async {
    camera = Camera();

    // This is required for the camera to work.
    camera?.gameRef = this;

    // Not required but recommend to set it now or when you set the follow target.
    camera?.worldBounds = yourWorldBounds;

    // Rest of your on load code.
  }

  // ...
```

The camera can also be made aware of which position to follow, this is an optional feature as you 
can also use the camare for just moving,snapping or shaking.

To do this the `Camera` class provides multiple methods for it but let's showcase the simplest one 
and that is the `followVector2`:

```dart
  // Somewhere in your code.

  camera?.followVector2(
    yourPositionToFollow,
    worldBounds: yourWorldBounds, // Optional to pass, it will overwrite the previous bounds.
  );
```

Now that the camera is created and it is aware of both the world bounds and the position it should 
follow, it can be used to translate the canvas in the render method:

```dart
  // ...

  void render(Canvas canvas) {
    camera?.apply(canvas); // This will apply the camera transformation.

    // Rest of your rendering code.
  }

  // ...
```

The only thing left to do is to call the `update` method on the `Camera` so it can smoothly follow 
your given position:

```dart
  // ...

  void update(double dt) {
    camera?.update(dt);

    // Rest of your update code.
  }

  // ...
```
