<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
A Flutter-based game engine.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
## Documentation

The full documentation for Flame can be found on
[docs.flame-engine.org](https://docs.flame-engine.org/).

To change the version of the documentation, use the version selector noted with `version:` in the
top of the page.

**Note**: The documentation that resides in the main branch is newer than the released documentation
on the docs website.

Other useful links:

- [The official Flame site](https://flame-engine.org/).
- [Examples](https://examples.flame-engine.org/) of most features which can be tried out from your
  browser.
  - To access the code for each example, press the `< >` button in the top right corner.
- [Tutorials](https://tutorials.flame-engine.org/) - A simple tutorial to get started.
- [API Reference](https://pub.dev/documentation/flame/latest/) - The generated dartdoc API
  reference.
- [awesome-flame](https://github.com/flame-engine/awesome-flame) - A curated list of Tutorials,
  Games, Libraries and Articles.


## Help

There is a Flame community on [Blue Fire's Discord server](https://discord.gg/5unKpdQD78) where you
can ask any of your Flame related questions.

If you are more comfortable with StackOverflow, you can also create a question there. Add the
[Flame tag](https://stackoverflow.com/questions/tagged/flame), to make sure that anyone following
the tag can help out.


## Features

The goal of the Flame Engine is to provide a complete set of out-of-the-way solutions for common
problems that games developed with Flutter might share.

Some of the key features provided are:

- A game loop.
- A component/object system (FCS).
- Effects and particles.
- Collision detection.
- Gesture and input handling.
- Images, animations, sprites, and sprite sheets.
- General utilities to make development easier.

On top of those features, you can augment Flame with bridge packages. Through these libraries,
you will be able to access bindings to other packages, including custom Flame components and
helpers, in order to make integrations seamless.

Flame officially provides bridge libraries to the following packages:

- [flame_audio](https://github.com/flame-engine/flame/tree/main/packages/flame_audio) for
  [AudioPlayers](https://github.com/bluefireteam/audioplayers): Play multiple audio files
  simultaneously.
- [flame_bloc](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc) for
  [Bloc](https://github.com/felangel/bloc): A predictable state management library.
- [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas) for
  [FireAtlas](https://github.com/flame-engine/fire-atlas): Create texture atlases for games.
- [flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) for
  [Forge2D](https://github.com/flame-engine/forge2d): A Box2D physics engine.
- [flame_lint](https://github.com/flame-engine/flame/tree/main/packages/flame_lint) -
  Our set of linting (`analysis_options.yaml`) rules.
- [flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) for
  [Oxygen](https://github.com/flame-engine/oxygen): A lightweight Entity Component System (ECS)
  framework.
- [flame_rive](https://github.com/flame-engine/flame/tree/main/packages/flame_rive) for
  [Rive](https://rive.app/): Create interactive animations.
- [flame_svg](https://github.com/flame-engine/flame/tree/main/packages/flame_svg) for
  [flutter_svg](https://github.com/dnfield/flutter_svg): Draw SVG files in Flutter.
- [flame_tiled](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled) for
  [Tiled](https://www.mapeditor.org/): 2D tile map level editor.


## Sponsors

The Flame Engine's top sponsors:

[![Very Good Ventures](https://raw.githubusercontent.com/flame-engine/flame/main/media/unicorn_two_toned.png)](https://verygood.ventures/)

[![Cypher Stack](https://raw.githubusercontent.com/flame-engine/flame/main/media/logo_cypherstack.png)](https://cypherstack.com/)

Want to sponsor Flame? Check our Patreon on the section below, or contact us on Discord.


## Support

The simplest way to show us your support is by giving the project a star.

You can also support us by becoming a patron on Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

Or by making a single donation by buying us a coffee:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

You can also show on your repository that your game is made with Flame by using one of the following
badges:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)

```txt
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```


## Contributing

Have you found a bug or have a suggestion of how to enhance Flame? Open an issue and we will take a
look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just make sure to create it from the
correct branch (main) and follow the [checklist](.github/pull_request_template.md) which will
appear when you open the PR.

For bigger changes, or if in doubt, make sure to talk about your contribution to the team. Either
via an issue, GitHub discussion, or reach out to the team either using the
[Discord server](https://discord.gg/pxrBmy4).


## Credits

- The [Blue Fire team](https://github.com/orgs/bluefireteam/people), who are continuously
  working on maintaining and improving Flame and its ecosystem.
- All the friendly contributors and people who are helping out in the community.
