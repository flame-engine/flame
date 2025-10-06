# Getting Started

There are a few important things to note before you even start playing with this package.

The GPU-powered 3D support depends on the still experimental
[Flutter GPU](https://github.com/flutter/flutter/wiki/Flutter-GPU), which in turn depends on
Impeller. This means a few things:

- Since **Flutter GPU** and **Impeller** are still experimental, this package is also considered
  experimental and may have breaking changes at any time.
- The only platforms that we have explicitly tested so far for support were Android, iOS, and macOS.
- You need to enable Impeller, if not already enabled by default (see below).


## Enabling Impeller

Then, you need to enable Impeller, if not already enabled by default. For example, for macOS, add
the following to the generated `macos/runner/Info.plist` directory:

```xml
<dict>
  ...
  <key>FLTEnableImpeller</key>
  <true/>
  <key>FLTEnableFlutterGPU</key>
  <true/>
</dict>
```

Alternatively, you can run Flutter with this flag instead:

```bash
flutter run --enable-flutter-gpu
```


## Playground & Examples

You can find a "playground"-style example of using `flame_3d` in the `packages/flame_3d/example`
directory. It contains multiple "setups" that you can switch using the built-in console commands.

You can also find three more complex examples below:

- [Defend the Donut](https://github.com/flame-engine/defend_the_donut/) - a simple first-person
  spaceship game involving a giant space donut.
- [Collect the Donut](https://github.com/luanpotter/collect_the_donut) - a simple third-person game
  where you control a low-poly rogue and can attack skeletons and collect donuts.
- [Flutter & Friends 2025 Workshop](https://github.com/luanpotter/flutter_and_friends_slides) - our
  talk at Flutter & Friends 2025, which includes a demo showcasing how to setup multiple camera
  styles.
