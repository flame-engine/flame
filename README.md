<!-- markdownlint-disable MD013 -->
<p align="right">
  <a href="https://docs.flutter.dev/packages-and-plugins/favorites">
    <img alt="Flutter favorite" width="100px" src="https://github.com/flame-engine/flame/assets/744771/aa5d5acd-e82b-48bc-ad81-2ab146d72ecb">
  </a>
</p>

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
  <a title="Pub" href="https://pub.dev/packages/flame"><img src="https://img.shields.io/pub/v/flame.svg?style=popout"/></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
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
- [Tutorials](https://docs.flame-engine.org/main/tutorials/tutorials.html) - Some simple tutorials
  to get started.
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

- [flame_audio][flame_audio] for [AudioPlayers][audioplayers]: Play multiple audio files
simultaneously.
- [flame_bloc][flame_bloc] for [Bloc][bloc]: A predictable state management library.
- [flame_fire_atlas][flame_fire_atlas] for [FireAtlas][fireatlas]: Create texture atlases for games.
- [flame_forge2d][flame_forge2d] for [Forge2D][forge2d]: A Box2D physics engine.
- [flame_isolate][flame_isolate] - Makes it easy to use [Flutter Isolates][flutter_isolates] in
a Flame game.
- [flame_lint][flame_lint] - Our set of linting (`analysis_options.yaml`) rules.
- [flame_lottie][flame_lottie] - Support for [Lottie][lottie] animation in Flame.
- [flame_network_assets][flame_network_assets] - Helpers to load game assets from
network.
- [flame_oxygen][flame_oxygen] for [Oxygen][oxygen]: A lightweight Entity Component System (ECS)
framework.
- [flame_rive][flame_rive] for [Rive][rive]: Create interactive animations.
- [flame_svg][flame_svg] for [flutter_svg][flutter_svg]: Draw SVG files in Flutter.
- [flame_tiled][flame_tiled] for [Tiled][tiled]: 2D tile map level editor.


## Sponsors

The Flame Engine's top sponsors:

[![Cypher Stack](https://raw.githubusercontent.com/flame-engine/flame/main/media/logo_cypherstack.png)](https://cypherstack.com/)

Do you or your company want to sponsor Flame?
Check out our [OpenCollective page](https://opencollective.com/blue-fire), which is also mentioned
in the section below, or contact us on [Discord](https://discord.gg/pxrBmy4).


## Support

The simplest way to show us your support is by giving the project a star! :star:

You can also support us monetarily by donating through OpenCollective:

<a href="https://opencollective.com/blue-fire/donate" target="_blank">
  <img src="https://opencollective.com/blue-fire/donate/button@2x.png?color=blue" width=200 />
</a>

Through GitHub Sponsors:

<a href="https://github.com/sponsors/bluefireteam" target="_blank">
  <img
    src="https://img.shields.io/badge/Github%20Sponsor-blue?style=for-the-badge&logo=github&logoColor=white"
    width=200
  />
</a>

Or by becoming a patron on Patreon:

<a href="https://www.patreon.com/bluefireoss" target="_blank">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button.png" width=200 />
</a>

You can also show on your repository that your game is made with Flame by using one of the following
badges:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)

```txt
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)
```


## Contributing

Have you found a bug or have a suggestion of how to enhance Flame? Open an issue and we will take a
look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just make sure to create it from the
correct branch (main) and follow the [checklist](.github/pull_request_template.md) which will
appear when you open the PR.

Also, before you start, make sure to read our [Contributing Guide](CONTRIBUTING.md).

For bigger changes, or if in doubt, make sure to talk about your contribution to the team. Either
via an issue, GitHub discussion, or reach out to the team either using the
[Discord server](https://discord.gg/pxrBmy4).


## Credits

- The [Blue Fire team](https://github.com/orgs/bluefireteam/people), who are continuously
  working on maintaining and improving Flame and its ecosystem.
- All the friendly contributors and people who are helping out in the community.

[flame_audio]: https://github.com/flame-engine/flame/tree/main/packages/flame_audio
[audioplayers]: https://github.com/bluefireteam/audioplayers
[flame_bloc]: https://github.com/flame-engine/flame/tree/main/packages/flame_bloc
[bloc]: https://github.com/felangel/bloc
[flame_fire_atlas]: https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas
[fireatlas]: https://github.com/flame-engine/fire-atlas
[flame_forge2d]: https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d
[forge2d]: https://github.com/flame-engine/forge2d
[flame_isolate]: https://github.com/flame-engine/flame/tree/main/packages/flame_isolate
[flutter_isolates]: https://api.flutter.dev/flutter/dart-isolate/Isolate-class.html
[flame_lint]: https://github.com/flame-engine/flame/tree/main/packages/flame_lint
[flame_lottie]: https://github.com/flame-engine/flame/tree/main/packages/flame_lottie
[lottie]: https://airbnb.design/lottie/
[flame_network_assets]: https://github.com/flame-engine/flame/tree/main/packages/flame_network_assets
[flame_oxygen]: https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen
[oxygen]: https://github.com/flame-engine/oxygen
[flame_rive]: https://github.com/flame-engine/flame/tree/main/packages/flame_rive
[rive]: https://rive.app/
[flame_svg]: https://github.com/flame-engine/flame/tree/main/packages/flame_svg
[flutter_svg]: https://github.com/dnfield/flutter_svg
[flame_tiled]: https://github.com/flame-engine/flame/tree/main/packages/flame_tiled
[tiled]: https://www.mapeditor.org/
