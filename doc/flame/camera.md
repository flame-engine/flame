# Camera & World

Example of a simple game structure:

```text
FlameGame
├── World
│   ├── Player
│   └── Enemy
└── CameraComponent
    ├── Viewfinder
    │   ├── HudButton
    │   └── FpsTextComponent
    └── Viewport
```

In order to understand how the `CameraComponent` works, imagine that your game
world is an entity that exists *somewhere* independently from your application.
Imagine that your game is merely a window through which you can look into that
world. That you can close that window at any moment, and the game world would
still be there. Or, on the contrary, you can open multiple windows that all look
at the same world (or different worlds) at the same time.

With this mindset, we can now understand how the `CameraComponent` works.

First, there is the [World](#world) class, which contains all components that are
inside your game world. The `World` component can be mounted anywhere, for
example at the root of your game class, like the built-in `World` is.

Then, a [CameraComponent](#cameracomponent) class that "looks at" the [World](#world). The
`CameraComponent` has a [Viewport](#viewport) and a [Viewfinder](#viewfinder)
inside of it, allowing both the flexibility of rendering the world at any place
on the screen, and also control the viewing location and angle. The
`CameraComponent` also contains a [backdrop](#backdrop) component which is
statically rendered below the world.


## World

This component should be used to host all other components that comprise your
game world. The main property of the `World` class is that it does not render
through traditional means -- instead it is rendered by one or more
[CameraComponent](#cameracomponent)s to "look at" the world. In the `FlameGame` class there is
one `World` called `world` which is added by default and paired together with
the default `CameraComponent` called `camera`.

A game can have multiple `World` instances that can be rendered either at the
same time, or at different times. For example, if you have two worlds A and B
and a single camera, then switching that camera's target from A to B will
instantaneously switch the view to world B without having to unmount A and
then mount B.

Just like with most `Component`s, children can be added to `World` by using the
`children` argument in its constructor, or by using the `add` or `addAll`
methods.

For many games you want to extend the world and create your logic in there,
such a game structure could look like this:

```dart
void main() {
  runApp(GameWidget(FlameGame(world: MyWorld())));
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    // Load all the assets that are needed in this world
    // and add components etc.
  }
}
```


## CameraComponent

This is a component through which a `World` is rendered. Multiple cameras can
observe the same world at the same time.

There is a default `CameraComponent` called `camera` on the `FlameGame` class
which is paired together with the default `world`, so you don't need to create
or add your own `CameraComponent` if your game doesn't need to.

A `CameraComponent` has two other components inside: a [Viewport](#viewport) and a
[Viewfinder](#viewfinder), those components are always children of a camera.

The `FlameGame` class has a `camera` field in its constructor, so you can set
what type of default camera that you want, like this camera with a
[fixed resolution](#cameracomponent-with-fixed-resolution) for example:

```dart
void main() {
  runApp(
    GameWidget(
      FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: 800,
          height: 600,
        ),
        world: MyWorld(),
      ),
    ),
  );
}
```

There is also a static property `CameraComponent.currentCamera` and it returns
the camera object that currently performs rendering. This is needed only for
certain advanced use cases where the rendering of a component depends on the
camera settings. For example, some components may decide to skip rendering
themselves and their children if they are outside of the camera's viewport.


### CameraComponent with fixed resolution

This named constructor will let you pretend that the user's device has a fixed resolution of your
choice. For example:

```dart
final camera = CameraComponent.withFixedResolution(
  world: myWorldComponent,
  width: 800,
  height: 600,
);
```

This will create a camera with a viewport centered in the middle of the screen, taking as much
space as possible while still maintaining the 4:3 (800x600) aspect ratio, and showing a game world region
of size 800 x 600.

A "fixed resolution" is very simple to work with, but it will underutilize the user's available
screen space, unless their device happens to have the same aspect ratio as your chosen dimensions.


## Viewport

The `Viewport` is a window through which the `World` is seen. That window
has a certain size, shape, and position on the screen. There are multiple kinds
of viewports available, and you can always implement your own.

The `Viewport` is a component, which means you can add other components to it.
These child components will be affected by the viewport's position, but not
by its clip mask. Thus, if a viewport is a "window" into the game world, then
its children are things that you can put on top of the window.

Adding elements to the viewport is a convenient way to implement "HUD"
components.

The following viewports are available:

- `MaxViewport` (default) -- this viewport expands to the maximum size allowed
    by the game, i.e. it will be equal to the size of the game canvas.
- `FixedResolutionViewport` -- keeps the resolution and aspect ratio fixed, with black bars on the
    sides if it doesn't match the aspect ratio.
- `FixedSizeViewport` -- a simple rectangular viewport with predefined size.
- `FixedAspectRatioViewport` -- a rectangular viewport which expands to fit
    into the game canvas, but preserving its aspect ratio.
- `CircularViewport` -- a viewport in the shape of a circle, fixed size.


If you add children to the `Viewport` they will appear as static HUDs in front of the world.


## Viewfinder

This part of the camera is responsible for knowing which location in the
underlying game world we are currently looking at. The `Viewfinder` also
controls the zoom level, and the rotation angle of the view.

The `anchor` property of the viewfinder allows you to designate which point
inside the viewport serves as a "logical center" of the camera. For example,
in side-scrolling action games it is common to have the camera focused on the
main character who is displayed not in the center of the screen but closer to
the lower-left corner. This off-center position would be the "logical center"
of the camera, controlled by the viewfinder's `anchor`.

If you add children to the `Viewfinder` they will appear in front of the world,
but behind the viewport and with the same transformations as are applied to the
world, so these components are not static.

You can also add behavioral components as children to the viewfinder, for
example [effects](effects.md) or other controllers. If you for example would add a
`ScaleEffect` you would be able to achieve a smooth zoom in your game.


## Backdrop

To add static components behind the world you can add them to the `backdrop`
component, or replace the `backdrop` component. This is for example useful if
you want to have a static `ParallaxComponent` that shows behind a world that
contains a player that can move around.

Example:

```dart
camera.backdrop.add(MyStaticBackground());
```

or

```dart
camera.backdrop = MyStaticBackground();
```


## Camera controls

There are several ways to modify a camera's settings at runtime:

1. Use camera functions such as `follow()`, `moveBy()` and `moveTo()`.
   Under the hood, this approach uses the same effects/behaviors as in (2).

2. Apply effects and/or behaviors to the camera's `Viewfinder` or `Viewport`.
   The effects and behaviors are special kinds of components whose purpose is
   to modify some property of a component over time.

3. Do it manually. You can always override the `CameraComponent.update()`
   method (or the same method on the viewfinder or viewport) and within it
   change the viewfinder's position or zoom as you see fit. This approach may
   be viable in some circumstances, but in general it is not recommended.

The `CameraComponent` has several methods for controlling its behavior:

- `follow()` will force the camera to follow the provided target.
   Optionally you can limit the maximum speed of movement of the camera, or
   allow it to only move horizontally/vertically.

- `stop()` will undo the effect of the previous call and stop the camera
   at its current position.

- `moveBy()` can be used to move the camera by the specified offset.
   If the camera was already following another component or moving,
   those behaviors would be automatically cancelled.

- `moveTo()` can be used to move the camera to the designated point on
   the world map. If the camera was already following another component or
   moving towards another point, those behaviors would be automatically
   cancelled.

- `setBounds()` allows you to add limits to where the camera is allowed to go. These limits
   are in the form of a `Shape`, which is commonly a rectangle, but can also be any other shape.


### visibleWorldRect

The camera exposes property `visibleWorldRect`, which is a rect that describes the world's region
which is currently visible through the camera. This region can be used in order to avoid rendering
components that are out of view, or updating objects that are far away from the player less
frequently.

The `visibleWorldRect` is a cached property, and it updates automatically whenever the camera
moves or the viewport changes its size.


### canSee

The `CameraComponent` has a method called `canSee` which can be used to check
if a component is visible from the camera point of view.
This is useful for example to cull components that are not in view.

```dart
if (!camera.canSee(component)) {
   component.removeFromParent(); // Cull the component
}
```


### Post processing

[Post processing](rendering/post_processing.md) is a technique used in game development to apply visual
effects to a component tree after it has been rendered. This can be added to the camera via the
`postProcess` property.

```dart
camera.postProcess = PostProcessGroup(
  postProcesses: [
    PostProcessSequentialGroup(
      postProcesses: [
        FireflyPostProcess(),
        WaterPostProcess(),
      ],
    ),
    ForegroundFogPostProcess(),
  ],
);
```

Read more about this on [Post processing](rendering/post_processing.md).
