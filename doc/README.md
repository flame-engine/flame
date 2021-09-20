# Getting Started!

## About Flame

Flame is a modular Flutter game engine that provides a complete set of out-of-the-way solutions for
games. It takes advantage of the powerful infrastructure provided by Flutter but simplifies the code
you need to build your projects.

It provides you with a simple yet effective game loop implementation, and the necessary
functionalities that you might need in a game. For instance; input, images, sprites, sprite sheets,
animations, collision detection and a component system that we call Flame Component System (FCS for
short).

We also provide stand-alone packages that extend the Flame functionality:
- [flame_audio](https://pub.dev/packages/flame_audio) Which provides audio capabilities using the
  `audioplayers` package.
- [flame_forge2d](https://pub.dev/packages/flame_forge2d) Which provides physics capabilities using
  our own `Box2D` port called `Forge2D`.
- [flame_tiled](https://pub.dev/packages/flame_tiled) Which provides integration with the
  [tiled](https://pub.dev/packages/tiled) package.

You can pick and choose whichever parts you want, as they are all independent and modular.

The engine and its ecosystem is constantly being improved by the community, so please feel free to
reach out, open issues, PRs and make suggestions.

Give us a star if you want to help give the engine exposure and grow the community. :)

## Installation

Put the pub package as your dependency by putting the following in your `pubspec.yaml`:

```yaml
dependencies:
  flame: <VERSION>
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame/install).

then run `pub get` and you are ready to start using it!

The latest version can be found on [pub.dev](https://pub.dev/packages/flame/install).

## Getting started

There is a set of tutorials that you can follow to get started in the
[tutorials folder](https://github.com/flame-engine/flame/tree/main/tutorials).

Simple examples for all features can be found in the
[examples folder](https://github.com/flame-engine/flame/tree/main/examples).

You can also check out the
[awesome flame repository](https://github.com/flame-engine/awesome-flame#articles--tutorials),
It contains quite a lot of good tutorials and articles written by the community to get you started
with Flame.

```{toctree}
:caption: Basic concepts
:hidden:
File structure       <structure.md>
Game loop            <game.md>
Components           <components.md>
Platforms            <platforms.md>
Collision detection  <collision_detection.md>
Effects              <effects.md>
Camera & Viewport    <camera_and_viewport.md>
```
```{toctree}
:caption: Inputs
:hidden:
Gesture input   <gesture-input.md>
Keyboard input  <keyboard-input.md>
Other inputs    <other-inputs.md>
```
```{toctree}
:caption: Audio
:hidden:
General audio    <audio.md>
Background music <bgm.md>
```
```{toctree}
:caption: Rendering
:hidden:
Images, sprites and animations  <images.md>
Text rendering                  <text.md>
Colors and palette              <palette.md>
Particles                       <particles.md>
Layers                          <layers.md>
```
```{toctree}
:caption: Other Modules
:hidden:
Util           <util.md>
Widgets        <widgets.md>
Forge2D        <forge2d.md>
Oxygen         <oxygen.md>
Tiled          <tiled.md>
Debugging      <debug.md>
Splash screen  <splash_screen.md>
```