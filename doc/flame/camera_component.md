# Camera component

```{note}
This document describes a new experimental API. The more traditional approach
for handling a camera is described in [](camera_and_viewport.md).
```

Camera-as-a-component is an alternative way of structuring a game, an approach
that allows more flexibility in placing the camera, or even having more than
one camera simultaneously.

In order to understand how this approach works, imagine that your game world is
an entity that exists *somewhere* independently from your application. Imagine
that your game is merely a window through which you can look into that world.
That you can close that window at any moment, and the game world would still be
there. Or, on the contrary, you can open multiple windows that all look at the
same world (or different worlds) at the same time.

With this mindset, we can now understand how camera-as-a-component works.

First, there is the [](#world) class, which contains all components that are
inside your game world. The `World` component can be mounted anywhere, for
example at the root of your game class.

Then, a [](#cameracomponent) class that "looks at" the `World`. The
`CameraComponent` has a `Viewport` and a `Viewfinder` inside, allowing both the
flexibility of rendering the world at any place on the screen, and also control
the viewing location and angle.


## World

This component should be used to host all other components that comprise your
game world. The main property of the `World` class is that it does not render
through traditional means -- instead, create one or more [](#cameracomponent)s
to "look at" the world.

A game can have multiple `World` instances that can be rendered either at the
same time, or at different times. For example, if you have two worlds A and B
and a single camera, then switching that camera's target from A to B will
instantaneously switch the view to world B without having to unmount A and
then mount B.

Just like with most `Component`s, children can be added to `World` by using the
`children` argument in its constructor, or by using the `add` or `addAll`
methods.


## CameraComponent

This is a component through which a `World` is rendered. It requires a
reference to a `World` instance during construction; however later the target
world can be replaced with another one. Multiple cameras can observe the same
world at the same time.

A `CameraComponent` has two other components inside: a [](#viewport) and a
[](#viewfinder). Unlike the `World` object, the camera owns the viewport and
the viewfinder, which means those components are children of the camera.

There is also a static property `CameraComponent.currentCamera` which is not
null only during the rendering stage, and it returns the camera object that
currently performs rendering. This is needed only for certain advanced use
cases where the rendering of a component depends on the camera settings. For
example, some components may decide to skip rendering themselves and their
children if they are outside of the camera's viewport.


### CameraComponent.withFixedResolution()

This factory constructor will let you pretend that the user's device has a fixed resolution of your
choice. For example:

```dart
final camera = CameraComponent.withFixedResolution(
  world: myWorldComponent,
  width: 800,
  height: 600,
);
```

This will create a camera with a viewport centered in the middle of the screen, taking as much
space as possible while still maintaining the 800:600 aspect ratio, and showing a game world region
of size 800 x 600.

A "fixed resolution" is very simple to work with, but it will underutilize the user's available
screen space, unless their device happens to have the same pixel ratio as your chosen dimensions.


## Viewport

The `Viewport` is a window through which the `World` is seen. That window
has a certain size, shape, and position on the screen. There are multiple kinds
of viewports available, and you can always implement your own.

The `Viewport` is a component, which means you can add other components to it.
These children components will be affected by the viewport's position, but not
by its clip mask. Thus, if a viewport is a "window" into the game world, then
its children are things that you can put on top of the window.

Adding elements to the viewport is a convenient way to implement "HUD"
components.

The following viewports are available:

- `MaxViewport` (default) -- this viewport expands to the maximum size allowed
    by the game, i.e. it will be equal to the size of the game canvas.
- `FixedSizeViewport` -- a simple rectangular viewport with predefined size.
- `FixedAspectRatioViewport` -- a rectangular viewport which expands to fit
    into the game canvas, but preserving its aspect ratio.
- `CircularViewport` -- a viewport in the shape of a circle, fixed size.


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

Components added to the `Viewfinder` as children will be rendered as if they
were part of the world (but on top). It is more useful to add behavioral
components to the viewfinder, for example [](effects.md) or other controllers.


## Camera controls

There are several ways to modify camera's settings at runtime:

  1. Do it manually. You can always override the `CameraComponent.update()`
     method (or the same method on the viewfinder or viewport) and within it
     change the viewfinder's position or zoom as you see fit. This approach may
     be viable in some circumstances, but in general it is not recommended.

  2. Apply effects and/or behaviors to the camera's `Viewfinder` or `Viewport`.
     The effects and behaviors are special kinds of components whose purpose is
     to modify over time some property of a component that they attach to.

  3. Use special camera functions such as `follow()` and `moveTo()`. Under the
     hood, this approach uses the same effects/behaviors as in (2).

Camera has several methods for controlling its behavior:

- `Camera.follow()` will force the camera to follow the provided target.
   Optionally you can limit the maximum speed of movement of the camera, or
   allow it to move horizontally/vertically only.

- `Camera.stop()` will undo the effect of the previous call and stop the camera
   at its current position.

- `Camera.moveTo()` can be used to move the camera to the designated point on
   the world map. If the camera was already following another component or
   moving towards another point, those behaviors would be automatically
   cancelled.

- `Camera.setBounds()` allows you to add limits to where the camera is allowed to go. These limits
   are in the form of a `Shape`, which is commonly a rectangle, but can also be any other shape.


## Comparison to the traditional camera

Compared to the normal [Camera](camera_and_viewport.md), the `CameraComponent`
has several advantages and drawbacks.

Pros:

- Multiple cameras can be added to the game at the same time;
- More flexibility in choosing the placement and the size of the viewport;
- Switching camera from one world to another can happen instantaneously,
    without having to unmount one world and then mount another;
- Support rotation of the world view;
- Effects can be applied either to the viewport, or to the viewfinder;
- More flexible camera controllers.
