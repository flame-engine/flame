<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
基于 Flutter 的游戏引擎。
</p>

<p align="center">
  <a title="Pub" href="https://pub.flutter-io.cn/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
</p>

---

[English](/README.md) | 简体中文 | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md) | [Español](/i18n/README-ES.md) | [日本語](/i18n/README-JA.md)

---

## 文档

完整的 Flame 文档可在 [docs.flame-engine.org](https://docs.flame-engine.org/) 查看。

如果你需要查看其他版本的文档，请使用网站顶部的版本选择器进行切换。

**注意**：主分支的文档比已发布在网站上的文档版本更新。

其他资源：
 - [官方网站](https://flame-engine.org/) 。
 - [示例](https://examples.flame-engine.org/) 可在浏览器上尝试大部分功能。
 - [教程](https://tutorials.flame-engine.org/) - 快速起步的教程。
 - [API 文档](https://pub.flutter-io.cn/documentation/flame/latest/) - 基于 dartdoc 生成的 API 文档。
 - [Flame 中文网（非官方）](https://www.flame-cn.com/) 。
 - [Flame 中文文档（非官方）](https://docs.flame-cn.com/) 。

## 问题互助

国内无法使用 Discord 或希望快速学习 Flame 的用户，
欢迎加入 [「Flame 交流」QQ 群](https://jq.qq.com/?_wv=1027&k=5ETLFm3)
（非官方, 针对国内用户的讨论群）。

在 [Blue Fire 的 Discord 频道](https://discord.gg/5unKpdQD78)
内有我们的 Flame 社区，你可以在该频道咨询有关 Flame 的问题。

如果你更倾向于使用 StackOverflow，你也可以在上面发表问题。
添加 [Flame 标签](https://stackoverflow.com/questions/tagged/flame)
后关注该标签的人可以看到并帮助解决问题。

## 项目功能

Flame 引擎的目的是为使用 Flutter 开发的游戏会遇到的常见问题提供一套完整的解决方案。

目前 Flame 提供了以下功能：

- 游戏循环 (game loop)
- 组件/对象系统 (FCS)
- 特效与粒子效果
- 碰撞检测
- 手势和输入支持
- 图片、动画、精灵图 (sprite) 以及精灵图组
- 一些简化开发的实用工具类

除了以上的功能以外，你可以使用一些桥接 Flame 的 package 来增强引擎本身的功能。
通过这些桥接 package，你可以访问 Flame 的组件、帮助程序，
或是与其他 package 进行绑定，从而达到平滑集成的效果。
目前我们有以下的桥接 package：

- [flame_audio](https://github.com/flame-engine/flame/tree/main/packages/flame_audio) 桥接
  [AudioPlayers](https://github.com/bluefireteam/audioplayers) ：可同时播放多个音频。
- [flame_bloc](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc) 桥接
  [Bloc](https://github.com/felangel/bloc) ：BloC 状态管理。
- [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas) 桥接
  [FireAtlas](https://github.com/flame-engine/fire-atlas) ：为游戏创建纹理图集。
- [flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) 桥接
  [Forge2D](https://github.com/flame-engine/forge2d) ：基于 Box2D 的物理引擎
- [flame_lint](https://github.com/flame-engine/flame/tree/main/packages/flame_lint) -
  引擎的代码格式规则 (`analysis_options.yaml`)。
- [flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) 桥接
  [Oxygen](https://github.com/flame-engine/oxygen) ：轻量的实体-组件-系统 (ECS)。
- [flame_rive](https://github.com/flame-engine/flame/tree/main/packages/flame_rive) 桥接
  [Rive](https://rive.app/) ：创建可交互的动画。
- [flame_svg](https://github.com/flame-engine/flame/tree/main/packages/flame_svg) 桥接
  [flutter_svg](https://github.com/dnfield/flutter_svg) ：在 Flutter 中绘制 SVG。
- [flame_tiled](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled) 桥接
  [Tiled](https://www.mapeditor.org/) ：二维平面的地图编辑器。

## 赞助者

Flame 引擎最大的赞助者：

[![Cypher Stack](/media/logo_cypherstack.png)](https://cypherstack.com/)

如果你想要赞助 Flame，请查看下方的 Pateron 信息，或在 Discord 频道中联系我们。

## 支持我们

顺手点一颗 Star，就是你对我们的最直接的支持！

你也可以通过 Patreon 来支持我们：

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

或者通过 Buy Me A Coffee 捐赠我们：

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

你也可以在仓库中展示下面的其中一个徽章，表示游戏是通过 Flame 制作的，来支持我们:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## 贡献

如果你找到了 bug 或对 Flame 有更好的建议，请创建一个 issue，我们将会尽快处理。

你想通过 PR 进行贡献吗？我们欢迎 PR，只要确保你的分支是从主分支 (main) 创建的，
并遵循创建 PR 时的 [PR 检查单](/.github/pull_request_template.md) 即可。

在处理大改动或对改动有疑问时，确保你和团队有充分的沟通。
你可以通过 issue、GitHub 讨论 (discussion) 或是在
[Discord 频道](https://discord.gg/pxrBmy4) 联系团队。

## 立即开始

你可以在 [tutorials.flame-engine.org](https://tutorials.flame-engine.org)
找到一个简单的新手教程，也可以在 [examples.flame-engine.org](https://examples.flame-engine.org)
找到包含了大部分 Flame 功能的示例。
若你想查看示例中的代码，点击右上角的 `< >` 按钮。

### 特别突出的社区教程

> 由于网络条件，以下内容你可能无法访问。

- @Devowl 的 Flutter & Flame 系列：
  - [第 1 步：构建你的游戏](https://medium.com/flutter-community/flutter-flame-step-1-create-your-game-b3b6ee387d77)
  - [第 2 步：游戏的基础](https://medium.com/flutter-community/flutter-flame-step-2-game-basics-48b4493424f3)
  - [第 3 步：精灵图和输入操作](https://blog.devowl.de/flutter-flame-step-3-sprites-and-inputs-7ca9cc7c8b91)
  - [第 4 步：碰撞和视图区域](https://blog.devowl.de/flutter-flame-step-4-collisions-viewport-ff2da048e3a6)
  - [第 5 步：逐级生成和相机视角](https://blog.devowl.de/flutter-flame-step-5-level-generation-camera-62a060a286e3)

- 其他教程:
  - @Vguzzi 的文章 [使用 Flame 在 Flutter 中制作游戏](https://www.raywenderlich.com/27407121-building-games-in-flutter-with-flame-getting-started)
  - @DevKage 的 YouTube 系列视频：[Dino run tutorial](https://www.youtube.com/playlist?list=PLiZZKL9HLmWOmQgYxWHuOHOWsUUlhCCOY)

我们还在 [awesome-flame](https://github.com/flame-engine/awesome-flame)
提供了一系列精选的游戏、组件库和文章。

请留意，部分文章的内容可能已稍微过时，但它们仍然有很好的指导意义。

## 感谢

 * 一直在为 Flame 及其生态作出贡献和维护的 [Blue Fire 团队](https://github.com/orgs/bluefireteam/people) 。
 * 所有友善的贡献者和在社区中提供帮助的人。

### 本地化文档翻译：
 * [HarrisonQI](https://github.com/HarrisonQi)
 * [Alex Li](https://github.com/AlexV525)
