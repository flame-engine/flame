[![Pub](https://img.shields.io/pub/v/flame.svg?style=popout)](https://pub.dartlang.org/packages/flame) ![Test](https://github.com/flame-engine/flame/workflows/Test/badge.svg?branch=master&event=push) [![Discord](https://img.shields.io/discord/509714518008528896.svg)](https://discord.gg/pxrBmy4)

# :fire: flame

<img src="https://i.imgur.com/vFDilXT.png" width="400">

[English](README.md) | 简体中文 | [Polski](README-PL.md)

> 本篇为社区版翻译, 目前针对版本: 0.28.0

一款简约的Flutter游戏引擎.

## 问题互助

我们在Fireslime的Discord上有一个互助频道, [点击加入](https://discord.gg/pxrBmy4).

我们也有[FAQ](FAQ.md), 所以提问前请先在这里看看你有没有需要的答案.

国内用户欢迎加入[Flame QQ交流群](https://jq.qq.com/?_wv=1027&k=5ETLFm3)(非官方, 针对国内用户的讨论群, 较新)

## 项目目标

这个项目的目的是为使用Flutter进行开发的每个游戏都会遇到的常见问题提供一套完整的解决方案.

目前它提供了:
- 游戏循环(game loop)
- 组件/对象系统
- 内置物理引擎(box2d)
- 音频支持
- 特效与粒子效果
- 手势和输入支持
- 图片, 精灵(sprite)以及精灵组
- 基础Rive支持
- 和一些简化开发的实用工具类

你可以按需使用它们, 因为它们在某种程度上是相互独立的.

## 支持我们

顺手点一颗Star, 就可以提供你的帮助!

你也可以成为赞助者, 通过Patreon来支持我们:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/fireslime)

或者通过买杯咖啡捐赠我们:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/fireslime)

你也可以在仓库中展示下面的徽章之一, 表示游戏是通过Flame制作来支持我们:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## 贡献

__注意__: 我们目前在着手于发布Flame的第一个稳定版本, 所以, 除Bug修复外, `0.x`的版本更新将全部冻结. 如果你想贡献该版本, 请确保你的提交是修复Bug. 若想贡献稳定版本, 请务必将你的PR指向`v1.0.0`分支, 并且一定要将你的贡献讲出来, 并且可在 [Discord](https://discord.gg/pxrBmy4) 上访问该分支.

我们感激你以任何形式帮助我们! 评论, 建议, 提issues, 以及PR(Pull Request).

如果你找到了bug或者有使Flame更好的建议, 创建一个issue. 我们将会尽快处理.

你想通过PR做贡献吗? PR总是受欢迎的, 只要确保你的分支是`develop`, 并遵循[PR模板](.github/pull_request_template.md)即可.

## 立即开始

简体中文教程 [Alekhin](https://github.com/japalekhin) Tutorial Series (Simplified Chinese) by [HarrisonQI](https://github.com/HarrisonQi) 
- [Flame介绍](https://www.bugcatt.com/archives/279)
- [2D休闲游戏：消灭小飞蝇(1/5)](https://www.bugcatt.com/archives/292)
- [图形和动画(2/5)](https://www.bugcatt.com/archives/560)
- [界面和弹窗(3/5)](https://www.bugcatt.com/archives/562)
- [分数, 存档和音效(4/5)](https://www.bugcatt.com/archives/564)
- [收尾和打包(5/5)](https://www.bugcatt.com/archives/731)

我们还在[awesome-flame](https://github.com/flame-engine/awesome-flame) 项目上提供了一些精选的游戏, 库和文章.

## 文档&说明

你可以在在这里看到完整的[开发文档](doc/README.md)

你也可以在[这里](doc/examples)看到许多不同功能的示例(文档/demo), [点击此处](./example)来查看一个入门demo.

Flame的官方网站(其中包含文档), 请[点击此处](https://flame-engine.org/)


## 感谢

 * [Fireslime](https://fireslime.xyz), 负责维护Flame的团队.
 * 翻译: [HarrisonQI](https://github.com/HarrisonQi)
 * 所有友善的贡献者和在社区中提供帮助的人.
 * [Luanpotter](https://github.com/luanpotter)'s (the Flame founder)的 [audioplayers](https://github.com/luanpotter/audioplayer) 库, 来源于[rxlabz](https://github.com/rxlabz/audioplayer)的fork.
 * Dart的 [Box2D](https://github.com/google/box2d.dart).