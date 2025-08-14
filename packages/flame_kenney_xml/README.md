<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds support for parsing XML sprite sheets from https://kenney.nl, and other sprite sheets on the same format.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_kenney_xml" ><img src="https://img.shields.io/pub/v/flame_kenney_xml.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->


## Getting started

To get started, first add `flame_kenney_xml` as a dependency in your flutter project.

```bash
flutter pub add flame_kenney_xml
```

Then place the `spritesheet.json` in `assets/` and `spritesheet.png` in `assets/images/`
(or whatever the names of the files are).

Then load the image and the spritesheet using:

```dart
final spritesheet = await XmlSpriteSheet.load(
  image: 'spritesheet.png',
  xml: 'spritesheet.xml`,
);
```
