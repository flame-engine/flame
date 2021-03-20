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

then run `pub get` and you are ready to start using it!

The latest version can be found on [pub.dev](https://pub.dev/packages/flame/install).

## Getting started

There is a set of tutorials that you can follow to get started in the
[flame_tutorials](https://github.com/flame-engine/flame_tutorials) repository.

Simple examples for all features can be found in the
[examples folder](https://github.com/flame-engine/flame/tree/main/examples).

You can also check out the
[awesome flame repository](https://github.com/flame-engine/awesome-flame#articles--tutorials),
It contains quite a lot of good tutorials and articles written by the community to get you started
with Flame.
