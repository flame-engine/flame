<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Flutter ベースのゲームエンジンです。
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---

[English](/README.md) | [简体中文](/i18n/README-ZH.md) | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md) | [Español](/i18n/README-ES.md) | 日本語

---

## ドキュメント

Flame に関する全てのドキュメントは [docs.flame-engine.org](https://docs.flame-engine.org/) で確認できます。

ドキュメントのバージョンを変更する際には、ページ上部にある `version:` と書かれたバージョンセレクタを使用してください。

**Note**: main ブランチに存在するドキュメントは docs website でリリースされたドキュメントよりも新しいです。

その他の便利なリンク集:

- [The official Flame site](https://flame-engine.org/) - Flame の公式サイトです。
- [Examples](https://examples.flame-engine.org/) - あなたのブラウザで試すことができる主要な機能の例です。
- [Tutorials](https://tutorials.flame-engine.org/) - 簡単なチュートリアルを紹介します。
- [API Reference](https://pub.dev/documentation/flame/latest/) - dartdoc から生成された API リファレンスです。

## ヘルプ

あなたの Flame 関連のどんな疑問も質問できる Flame コミュニティが [Blue Fire's Discord server](https://discord.gg/5unKpdQD78) にあります。

もしあなたが StackOverflow のほうが好きなのであればそこで質問することもできます。その際にはあなたの質問をフォローできるように [Flame タグ](https://stackoverflow.com/questions/tagged/flame) を付けてください。

## 機能

Flame エンジンの目標は、Flutter で開発されたゲームに共通する問題に対して革新的な解決策を提供することです。

提供される主な機能の一部は以下の通りです:

- ゲームのループ。
- コンポーネント/オブジェクトシステム (FCS)。
- エフェクトやパーティクル。
- 障害物検知。
- ジェスチャーや入力制御。
- 画像、アニメーション、スプライトやスプライトシート。
- 開発を容易にする汎用的なユーティリティ。

上記の機能に加え、ブリッジパッケージで Flame を強化することができます。これらのライブラリを通して他のパッケージのバインディングにアクセスできるようになり、カスタムされた Flame コンポーネントやヘルパーを使用することでシームレスな統合を実現します。

Flame は公式に以下のパッケージのブリッジライブラリを提供しています:

- [flame_audio](https://github.com/flame-engine/flame/tree/main/packages/flame_audio) for
  [AudioPlayers](https://github.com/bluefireteam/audioplayers): 複数のオーディオファイルの同時再生を可能にします。
- [flame_bloc](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc) for
  [Bloc](https://github.com/felangel/bloc): よく知られた状態管理ライブラリです。
- [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas) for
  [FireAtlas](https://github.com/flame-engine/fire-atlas): ゲーム用テクスチャーアトラスの作成を可能にします。
- [flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) for
  [Forge2D](https://github.com/flame-engine/forge2d): Box2D の物理エンジンです。
- [flame_lint](https://github.com/flame-engine/flame/tree/main/packages/flame_lint) -
  Flame 開発で使用されている lint (`analysis_options.yaml`) ルールです。
- [flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) for
  [Oxygen](https://github.com/flame-engine/oxygen): 軽量な エンティティ・コンポーネント・システム (ECS) フレームワークです。
- [flame_rive](https://github.com/flame-engine/flame/tree/main/packages/flame_rive) for
  [Rive](https://rive.app/): インタラクティブなアニメーションを可能にします。
- [flame_svg](https://github.com/flame-engine/flame/tree/main/packages/flame_svg) for
  [flutter_svg](https://github.com/dnfield/flutter_svg): Flutter で SVG 画像を扱うことを可能にします。
- [flame_tiled](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled) for
  [Tiled](https://www.mapeditor.org/): 2D タイルマップのレベルエディターです。

## スポンサー

Flame エンジンのトップスポンサーは以下の通りです:

[![Cypher Stack](/media/logo_cypherstack.png)](https://cypherstack.com/)

Flame のスポンサーになることを希望する方は、以下のセクションにある私たちの Patreon か、または Discord で連絡してください。

## サポート

最も簡単にあなたのサポートを私たちに表明する方法はプロジェクトに星を付けることです。

Patreon でパトロンになることでも私たちをサポートできます:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

もしくは Buy Me A Coffee で寄付を行うことでも可能です:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

また、以下のいずれかを使用することであなたのゲームが Flame で作られていることをリポジトリに表示することができます:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## 貢献

バグを発見したか Flame を改善するための提案をお持ちでしょうか？できる限り迅速に確認しますので、イシューを発行してください。

もしくは PR で貢献したいですか？PR はいつでも歓迎ですが、必ず正しいブランチ（main）から作成することと、あなたが PR をオープンした際に表示される [checklist](.github/pull_request_template.md) を確認するようにしてください。

大きな変更がある場合、または疑問がある場合は、必ずあなたの貢献についてチームに話すようにしてください。イシューや GitHub ディスカッションを通して、もしくは [Discord server](https://discord.gg/pxrBmy4) を使ってチームと連絡をとってください。

## 開発を始めましょう

Flame を使用して開発を始める際の簡単なチュートリアルは [tutorials.flame-engine.org](https://tutorials.flame-engine.org) で確認できます。また、 [examples.flame-engine.org](https://examples.flame-engine.org) で Flame の主な機能の例を確認することができます。各例のコードにアクセスするためには右上の `< >` ボタンを押してください。

### ハイライトされたコミュニティーのチュートリアル

- @Devowl の Flutter & Flame シリーズ:

  - [Step 1: あなたのゲームを作ってみよう](https://medium.com/flutter-community/flutter-flame-step-1-create-your-game-b3b6ee387d77)
  - [Step 2: ゲームの基本](https://medium.com/flutter-community/flutter-flame-step-2-game-basics-48b4493424f3)
  - [Step 3: スプライトと入力](https://blog.devowl.de/flutter-flame-step-3-sprites-and-inputs-7ca9cc7c8b91)
  - [Step 4: 障害物とビューポート](https://blog.devowl.de/flutter-flame-step-4-collisions-viewport-ff2da048e3a6)
  - [Step 5: レベル生成とカメラ](https://blog.devowl.de/flutter-flame-step-5-level-generation-camera-62a060a286e3)

- その他のチュートリアル:
  - @Vguzzi の記事 [Building Games in Flutter with Flame](https://www.raywenderlich.com/27407121-building-games-in-flutter-with-flame-getting-started)
  - @DevKage の YouTube シリーズ [Dino run tutorial](https://www.youtube.com/playlist?list=PLiZZKL9HLmWOmQgYxWHuOHOWsUUlhCCOY)

私たちはゲーム、ライブラリ、記事に関する精選されたリストを [awesome-flame](https://github.com/flame-engine/awesome-flame) で提供しています。

ここまでで紹介した記事の一部は若干古くなっている可能性がありますが、参考にしてください。

## クレジット

- [Blue Fire team](https://github.com/orgs/bluefireteam/people): Flame とそのエコシステムの維持と改善に継続的に取り組んでいます。
- 全てのコミュニティを助けてくれる親切なコントリビューターや人々。
