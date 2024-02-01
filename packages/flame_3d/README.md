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
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
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
| Android  | ❌        |
| iOS      | ❌        |
| macOS    | ✅        |
| Windows  | ❌        |
| Linux    | ❌        |
| Web      | ❌        |

## Prologue

**STOP**, we know you are hyped up and want to start coding some funky 3D stuff but we first have to
set your expectations and clarify some things. So turn down your music, put away the coffee and make
some tea instead because you have to do some reading first!

This package provides 3D support for Flame but it depends on the still experimental 
[Flutter GPU](https://github.com/flutter/flutter/wiki/Flutter-GPU) which in turn depends on 
Impeller. The Flutter GPU is currently not shipped with Flutter so this package wont work without 
following the prerequisites steps.

Because we depend on Flutter GPU this package is also highly experimental. Our long term goal is to
eventually deprecate this package and integrate it into the core `flame` package, for more 
information on this see the [Roadmap](https://github.com/flame-engine/flame/blob/main/packages/flame_3d/ROADMAP.md).

This package does not guarantee that it will follow correct [semver](https://semver.org/) versioning
rules nor does it assure that it's APIs wont break. Be ready to constantly have to refactor your 
code if you are planning on using this package in a semi-production environment, which we do not
recommend. 

Documentation and tests might be lacking for quite a while because of the potential constant changes
of the API. Where possible we will try to provide in-code documentation and code examples to help
developers but our main goal for now is to enable the usage of 3D rendering within a Flame 
ecosystem.


## Prerequisites

Before you can get started with using this package a few steps have to happen first. Step one is 
switching to a specific commit on the Flutter tooling. Because this package is still experimental 
some of the features it requires are still being worked on from the Flutter side.

So to make sure you are using the same build that we use while developing you have to manually 
checkout a specific Flutter build. Thankfully we were able to simplify that process into a 
one-liner:

```sh
cd $(dirname $(which flutter)) && git checkout 8a5509ea6a277d48c15e5965163b08bd4ad4816a -q && echo "Engine commit: $(cat internal/engine.version)" && cd - >/dev/null
```

This will check out the GIT repo of your Flutter installation to the specific commit that we require
and also return the commit SHA of the Flutter Engine that it was build with. We need for step two.

Step two is setting up the Flutter GPU. You can follow the steps described in the [Flutter Wiki](https://github.com/flutter/flutter/wiki/Flutter-GPU#try-out-flutter-gpu). 
The engine commit that you should use is the one we got in step one.

Once you have cloned the Flutter engine you can add the `flutter_gpu` as an override dependency 
to your `pubspec.yaml` or in a `pubspec_overrides.yaml` file:

```yaml
dependency_overrides:
  flutter_gpu:
    path: <path_to_the_cloned_flutter_engine_directory>/lib/gpu
```

Step three would be to enable impeller for the macOS platform, add the following to the 
`Info.plist` in your `macos/` directory:

```xml
<dict>
    ...
	<key>FLTEnableImpeller</key>
	<true/>
</dict>
```

Now everything is set up you can start doing some 3D magic! You can check out the
[example](https://github.com/flame-engine/flame/tree/main/packages/flame_3d/example) to see how you
can set up a simple 3D environment using Flame.


## Building shaders

You can write your own shaders and use them on Materials. Currently Flutter does not do the bundling
of shaders for us so this package provides a simple dart script. Create your fragment and vertex 
shader in a `shaders` directory, make sure the file names are identical. Like so:

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