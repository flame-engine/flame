<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds markdown support for <a href="https://github.com/flame-engine/flame">Flame</a> using the <a href="https://github.com/dart-lang/markdown">markdown</a> package.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_markdown" ><img src="https://img.shields.io/pub/v/flame_markdown.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
# flame_markdown

This package facilitates the creation of Flame's TextNode hierarchies by leveraging markdown
strings.

It integrates with the `markdown` package to parse markdown strings into an AST and uses that AST to
create a `DocumentRoot` containing the equivalent list of nodes from Flame's text rendering
pipeline.

Add this as a dependency to your Flame game if you want to easily apply simple inline formatting to
text in your game (bold, italics), or if you want to create complex text documents with headings and
paragraphs and have them formatted by Flame's text layout system, without needing to manually
specify the `TextNode` tree structure.
