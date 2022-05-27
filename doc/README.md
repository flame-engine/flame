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
[awesome flame repository](https://github.com/flame-engine/awesome-flame#user-content-articles--tutorials),
It contains quite a lot of good tutorials and articles written by the community to get you started
with Flame.


## Outside of the scope of the engine

Games sometimes require complex feature sets depending on what the game is all about. And some of
those feature sets are outside of the scope of the Flame Engine ecosystem, in this section you can find
them, and also some recommendations of packages/services that can be used:


### Multiplayer (netcode)

Flame doesn't bundle any network feature, which may be needed to write online multiplayer games.

If you are building a multipler game, here are some recommendations of packages/services:

 - [Nakama](https://github.com/Allan-Nava/nakama-flutter): Nakama is an open-source server designed
 to power modern games and apps.
 - [Firebase](https://firebase.google.com/): Provides dozens of services that can be used to write
simpler multiplayer experiences.


### External assets

Flame doesn't bundle any helpers to load assets from an external source (external storage or online
sources).

But most of Flame's API can be loaded from concrete asset instances, for examples, `Sprite`s can be
created from `dart:ui`s `Image` instaces, so the user can write custom code to load images from
anywhere they need, and then load it into Flame's classes.

Here are some suggestions for http client packages:

 - [http](https://pub.dev/packages/http): A simple pacakage for perfoming http requests.
 - [Dio](https://pub.dev/packages/dio): A popular and powerful package for perfoming http requests.
