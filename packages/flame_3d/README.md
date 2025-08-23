<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds 3D support for <a href="https://github.com/flame-engine/flame">Flame</a> using the <a href="https://github.com/flutter/flutter/wiki/Flutter-GPU">Flutter GPU</a>.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_3d" ><img src="https://img.shields.io/pub/v/flame_3d.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
# flame_3d

This package provides an experimental implementation of 3D support for Flame. The main focus is to
explore the potential capabilities of 3D for Flame while providing a familiar API to existing Flame
developers.

Supported platforms:

| Platform | Supported |
| -------- | --------- |
| Android  | ✅        |
| iOS      | ✅        |
| macOS    | ✅        |
| Windows  | ❌        |
| Linux    | ❌        |
| Web      | ❌        |


## Prologue

**STOP**, we know you are hyped up and want to start coding some funky 3D stuff but we first have to
set your expectations and clarify some things. So turn down your music, put away the coffee and make
some tea instead because you have to do some reading first!

This package provides 3D support for Flame but it depends on the still experimental
[Flutter GPU](https://github.com/flutter/flutter/wiki/Flutter-GPU), which in turn depends on
Impeller.

Therefore, this package is also experimental; you can check our
[Roadmap](https://github.com/flame-engine/flame/blob/main/packages/flame_3d/ROADMAP.md)
for more details on our plans and what is currently supported.

This package does not guarantee that it will follow correct [semver](https://semver.org/) versioning
rules, nor does it assure that its APIs wont break. Be ready to constantly have to refactor your
code if you are planning on using this package, and potentially to have to contribute with
improvements and fixes. Please do not use this for production environments.

Documentation and tests might be lacking for quite a while because of the potential constant changes
of the API. Where possible, we will try to provide in-code documentation and code examples to help
developers but our main goal for now is to enable the usage of 3D rendering within a Flame
ecosystem.


## Prerequisites

In order to use flame_3d, you will need to ensure a few things. Firstly, the only platforms that we
have explicitly tested so far for support were Android, iOS, and macOS.

Then, you need to enable Impeller, if not already enabled by default. For example, for macOS, add
the following to the generated `macos/runner/Info.plist` directory:

```xml
<dict>
    ...
 <key>FLTEnableImpeller</key>
 <true/>
</dict>
```

You can also run Flutter with the flag:

```bash
flutter run --enable-flutter-gpu
```

Now everything is set up you can start doing some 3D magic! You can check out the
[example](https://github.com/flame-engine/flame/tree/main/packages/flame_3d/example) to see how you
can set up a simple 3D environment using Flame.

Also check our more advanced examples, [Collect the Donut](https://github.com/luanpotter/collect_the_donut)
and [Defend the Donut](https://github.com/flame-engine/defend_the_donut).


## Building shaders

If you are using the `SpatialMaterial` provided by `flame_3d`, you do not need to worry about shaders.

That being said, you can write your own shaders and use them on custom materials.
Currently, Flutter does not do the bundling of shaders for us so this package provides a simple
Dart script. Create your fragment and vertex shader in a `shaders` directory,
make sure the file names are identical. Like so:

- `my_custom_shader`.frag
- `my_custom_shader`.vert

You can then run `dart pub run flame_3d:build_shaders` to bundle the shaders. They will
automatically be placed in `assets/shaders`.

You can check out the
[default shaders](https://github.com/flame-engine/flame/tree/main/packages/flame_3d/shaders) if you
want to have some examples.


## Contributing

Have you found a bug or have a suggestion of how to enhance the 3D APIs? Open an issue and we will
take a look at it as soon as possible.

Do you want to contribute with a PR? PRs are always welcome, just make sure to create it from the
correct branch (main) and follow the [checklist](.github/pull_request_template.md) which will
appear when you open the PR.

For bigger changes, or if in doubt, make sure to talk about your contribution to the team. Either
via an issue, GitHub discussion, or reach out to the team using the
[Discord server](https://discord.gg/pxrBmy4).
