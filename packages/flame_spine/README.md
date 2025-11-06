# Flame Spine

Package to add [Spine](http://esotericsoftware.com/) support for the Flame game engine.

You can read more about the spine-flutter runtime and how to use it in the docs at their
[site](https://esotericsoftware.com/spine-flutter).


## License

The code and all associated assets of the `flame_spine` package is distributed under the
MIT License (see the LICENSE file). **HOWEVER**, as `flame_spine` includes Spine Runtime libraries,
your use of `flame_spine` in your games or other products is also subject to the terms and
conditions of the Spine Runtime License Agreement (see the LICENSE file).

**In particular, in order to use `flame_spine` you are required to obtain a valid Spine Editor
License.**


## Spine 4.2 vs Spine 4.3

Make sure that you are using the right version of `flame_spine` for your current version of the
Spine Editor.

For Spine 4.2, `v0.2.2` is the last release. Spine 4.3 support begins with `v0.3.0`.

To migrate from 4.2 to 4.3 models, make sure to re-export any existing 4.2 models through the 4.3
Spine Editor, and follow the `spine_flutter` [migration guide](https://pub.dev/packages/spine_flutter/changelog).

There is a [Spine CLI](https://en.esotericsoftware.com/spine-command-line-interface) available to assist with the re-exporting process.

Feel free to reach out on the [official forums](https://esotericsoftware.com/forum/) if you need more specific assistance.
