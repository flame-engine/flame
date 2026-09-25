<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
A command line tool for inspecting and controlling running <a href="https://github.com/flame-engine/flame">Flame</a> games.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_cli" ><img src="https://img.shields.io/pub/v/flame_cli.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->

# flame_cli

The `flame` command inspects and controls a Flame game that is running in debug mode, without
having to open the DevTools. This makes it possible for scripts and AI coding agents to, for
example, see what the game currently looks like.


## Installation

```shell
dart pub global activate flame_cli
```


## Usage

Start your game with `flame run` from your project directory. It takes the same arguments as
`flutter run`, and lets the other commands find the game:

```shell
flame run -d macos
```

Then render the whole game to a PNG image:

```shell
flame snapshot --output snapshot.png
```

List the components together with their ids, and render a single component:

```shell
flame tree
flame snapshot --component 220731871
```

If the game was started in another way, pass the Dart VM Service URI that `flutter run` prints to
the commands with `--uri`.

Run `flame --help` for all the commands and options, and see the
[documentation](https://docs.flame-engine.org/latest/flame/other/cli.html) for more information.
