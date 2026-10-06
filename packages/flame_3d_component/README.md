<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds 3D components (rendered by the <a href="https://github.com/bdero/flutter_scene">flutter_scene</a> engine) to the component tree of your <a href="https://github.com/flame-engine/flame">Flame</a> games.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_3d_component" ><img src="https://img.shields.io/pub/v/flame_3d_component.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->

# flame_3d_component

Package to add 3D objects, rendered by
[flutter_scene](https://pub.dev/packages/flutter_scene), to the regular 2D
component tree of a Flame game.

All the 3D rendering is done by [Flutter Scene](https://fscene.dev), the
realtime 3D engine for Flutter created and maintained by
[Brandon DeRosier (bdero)](https://github.com/bdero). Big thanks to him for
building it, and for the Flutter GPU work that makes it possible. Head over to
[fscene.dev](https://fscene.dev) for the engine's own documentation, guides,
and API reference.


## What this package is, and what it is not

This package is for when you want a 3D object in an otherwise 2D Flame game: a
spinning model in the menu, a 3D character on top of a 2D background, a dice
rolling across a board, a product preview inside your game UI. The `Component3D`
is a normal `PositionComponent`, so it is positioned, sized, scaled, rotated,
anchored, and layered exactly like a sprite, and it participates in Flame's
update and render loop like any other component.

It is **not** a 3D game engine and it is not meant to replace one. All of the
3D work, such as the scene graph, cameras, materials, lighting, animation,
model loading, and physics, is done by flutter_scene. This package only draws a
flutter_scene scene into a Flame component, nothing more. If you are building a
full 3D game, use flutter_scene directly, or the experimental
[flame_3d](https://pub.dev/packages/flame_3d) package, which is a separate
effort with a different purpose.

More [here](https://docs.flame-engine.org/main/bridge_packages/flame_3d_component/flame_3d_component.html).
