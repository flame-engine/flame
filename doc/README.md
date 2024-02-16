# Getting Started


## About Flame

Flame is a modular Flutter game engine that provides a complete set of out-of-the-way solutions for
games. It takes advantage of the powerful infrastructure provided by Flutter but simplifies the code
you need to build your projects.

It provides you with a simple yet effective game loop implementation, and the necessary
functionalities that you might need in a game. For instance; input, images, sprites, sprite sheets,
animations, collision detection, and a component system that we call Flame Component System (FCS for
short).

We also provide stand-alone packages that extend the Flame functionality which can be found in the
[Bridge Packages](bridge_packages/bridge_packages.md) section.

You can pick and choose whichever parts you want, as they are all independent and modular.

The engine and its ecosystem are constantly being improved by the community, so please feel free to
reach out, open issues and PRs as well as make suggestions.

Give us a star if you want to help give the engine exposure and grow the community. :)


## Installation

Add the `flame` package as a dependency in your `pubspec.yaml` by running the following command:

```console
flutter pub add flame
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame/install).

then run `flutter pub get` and you are ready to start using it!


## Getting started

There is a set of tutorials that you can follow to get started in the
[tutorials folder](https://github.com/flame-engine/flame/tree/main/doc/tutorials).

Simple examples for all features can be found in the
[examples folder](https://github.com/flame-engine/flame/tree/main/examples).

You can also check out the [awesome flame
repository](https://github.com/flame-engine/awesome-flame#user-content-articles--tutorials),
it contains quite a lot of good tutorials and articles written by the community
to get you started with Flame.


## Outside of the scope of the engine

Games sometimes require complex feature sets depending on what the game is all about. Some of these
feature sets are outside of the scope of the Flame Engine ecosystem, in this section you can find
them, and also some recommendations of packages/services that can be used:


### Multiplayer (netcode)

Flame doesn't bundle any network feature, which may be needed to write online multiplayer games.

If you are building a multiplayer game, here are some recommendations of packages/services:

- [Nakama](https://github.com/obrunsmann/flutter_nakama/): Nakama is an open-source server designed
 to power modern games and apps.
- [Firebase](https://firebase.google.com/): Provides dozens of services that can be used to write
simpler multiplayer experiences.
- [Supabase](https://supabase.com/): A cheaper alternative to Firebase, based on Postgres.
