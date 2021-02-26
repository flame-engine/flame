#

<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
A minimalistic Flutter game engine.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dartlang.org/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout&include_prereleases" /></a>
  <a title="Pub" href="https://pub.dartlang.org/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/Test/badge.svg?branch=master&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
</p>

---

[English](/README.md) | [简体中文](/i18n/README-ZH.md) | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md)

---

## About 1.0.0

Our goal is to release v1 soon. We are periodically launching RCs (release candidates) as we evolve the code, and we are already quite happy with where we are (but there might still be further changes). Our documentation is still not completely updated to v1, and things are still open to change.

Please use this version to get a preview of the new Flame version and also to give the team feedback about the new structure and/or features.

The `master` branch is the bleeding edge of the v1 migration. The `master-v0.x` branch is the latest v0 release (where we are still merging some patches and crucial fixes).

The current v1 release is `1.0.0-rc7` on pub. The latest stable version so far is `0.29.3`. Feel free to choose the one that better suits your need.

---

## Documentation

Note that the documentation in the master branch of this repo is newer than the latest released version.

Here you can find the documentation for different versions:
- Latest stable version: [Flame-engine website](https://flame-engine.org/)
- Latest stable version: [GitHub docs](https://github.com/flame-engine/flame/tree/master-v0.x/doc)
- Latest v1.0.0 version: [GitHub docs](https://github.com/flame-engine/flame/tree/1.0.0-rc6/doc)

The complete documentation can be found [here](doc/README.md).

Many examples of different features can be found [here](doc/examples) and a good starting example can be found [here](/example).

The official site for Flame, which also contains the documentation can be found [here](https://flame-engine.org/).

## Help

We have a Flame help channel on Fireslime's Discord, join it [here](https://discord.gg/pxrBmy4).

We also have a [FAQ](FAQ.md), so please search for your question there first.

## Goals

The goal of this project is to provide a complete set of out-of-the-way solutions for the common problems every game developed in Flutter will share.

Currently it provides you with:
 - a game loop
 - a component/object system
 - a physics engine (Forge2D, available through [flame_Forge2D](https://github.com/flame-engine/flame_Forge2D))
 - audio support
 - effects and particles
 - gesture and input support
 - images, sprites and sprite sheets
 - basic Rive support
 - and a few other utilities to make development easier

You can use whichever ones you want, as they are all somewhat independent.

## Support

The simplest way to show us your support is by giving the project a star.

You can also support us by becoming a patron on Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/fireslime)

Or by making a single donation by buying us a coffee:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/fireslime)

You can also show on your repository that your game is made with Flame by using one of the following badges:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Contributing

__Warning__: We are working on bringing Flame to its first stable version, updates on `0.x` versions are frozen, except for crucial bug fixes. If you want to contribute to that version, please be mindful of that, and use the `master-v0.x` branch. For contributions for v1, your PR must point to the `master` branch. If in doubt, make sure to talk about your contribution to the team, either via an issue or [Discord](https://discord.gg/pxrBmy4).

Any help is appreciated! Comments, suggestions, issues, PRs.

Have you found a bug or have a suggestion of how to enhance Flame, open an issue and we will take a look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just be sure to create it from the correct branch (see above) and follow the [checklist](.github/pull_request_template.md) which will appear when you open it.

## Getting started

Check out this great series of articles/tutorials written by [Alekhin](https://github.com/japalekhin)

 - [Create a Mobile Game with Flutter and Flame – Beginner Tutorial](https://jap.alekhin.io/create-mobile-game-flutter-flame-beginner-tutorial)
 - [2D Casual Mobile Game Tutorial – Step by Step with Flame and Flutter (Part 1 of 5)](https://jap.alekhin.io/2d-casual-mobile-game-tutorial-flame-flutter-part-1)
 - [Game Graphics and Animation Tutorial – Step by Step with Flame and Flutter (Part 2 of 5)](https://jap.alekhin.io/game-graphics-and-animation-tutorial-flame-flutter-part-2)
 - [Views and Dialog Boxes Tutorial – Step by Step with Flame and Flutter (Part 3 of 5)](https://jap.alekhin.io/views-dialog-boxes-tutorial-flame-flutter-part-3)
 - [Scoring, Storage, and Sound Tutorial – Step by Step with Flame and Flutter (Part 4 of 5)](https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4)
 - [Game Finishing and Packaging Tutorial – Step by Step with Flame and Flutter (Part 5 of 5)](https://jap.alekhin.io/game-finishing-packaging-tutorial-flame-flutter-part-5)

We also offer a curated list of Games, Libraries and Articles over at [awesome-flame](https://github.com/flame-engine/awesome-flame).

Note that some of the articles might be slightly outdated, but they are still useful.

## Credits

 * [Fireslime](https://fireslime.xyz), the team responsible for maintaining Flame.
 * All the friendly contributors and people who are helping in the community.
 * [Luanpotter](https://github.com/luanpotter)'s (the Flame founder) [audioplayers](https://github.com/luanpotter/audioplayer) lib, which in turn is forked from [rxlabz's](https://github.com/rxlabz/audioplayer).
 * The Dart port of [Box2D](https://github.com/google/box2d.dart).
