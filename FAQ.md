# FAQ

This file contains Frequently Asked Questions and their answers.
Please feel free to make PRs to amend this file with new questions.

## Any audio/music/sounds related problems

Flame only provides a thin wrapper over the
[audioplayers](https://github.com/luanpotter/audioplayers) library.
Please make sure the problem you are having is with Flame. If you have a low-level or hardware
related audio problem, probably it's something related to audioplayers, so please feel free to head
to that repository to search your problem or open your issue. If you indeed have a problem with the
Flame wrapper around audioplayers, then open an issue here.

## Drawing over the notch (for Android)

In order to draw over the notch, you must add the following line to your `styles.xml` file:

```xml
<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
```

For more details, please check
[this PR](https://github.com/impulse/flutters/commit/25d4ce726cd18e426483e605fe3668ec68b3c12c) from
[impulse](https://github.com/impulse).

## Common exceptions/errors

### ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized

Since Flutter 1.10.x, when using some of `Flame.device` methods, like the methods for enforcing the
device orientation, before the `runApp` statement, the following exception can happen:

```
E/flutter (16523): [ERROR:flutter/lib/ui/ui_dart_state.cc(151)] Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
E/flutter (16523): If you're running an application and need to access the binary messenger before `runApp()` has been called (for example, during plugin initialization), then you need to explicitly call the `WidgetsFlutterBinding.ensureInitialized()` first.
E/flutter (16523): If you're running a test, you can call the `TestWidgetsFlutterBinding.ensureInitialized()` as the first line in your test's `main()` method to initialize the binding.
```

To prevent that exception from happening, add the following line before calling those utilities
methods:

`WidgetsFlutterBinding.ensureInitialized();`

## Examples

We have a lot of examples! The simplest of all is in
[the package example folder](packages/flame/example/).
This folder must be called `example` and contain a single project, so it's a very simple generic
example game.

However there is another
[examples folder](https://github.com/flame-engine/flame/tree/main/examples/) directly in the git
root which showcases most of the features that exist in Flame.

If you want a more full-fledged game, please check:
 - [BGUG](https://github.com/bluefireteam/bgug): Blue Fire's open source fast paced side-scrolling
 platformer. It is mostly up-to-date with Flame and uses a good chunk of the features offered by the
 engine.
 - [renancaraujo](https://github.com/renancaraujo)'s port of the
 [trex](https://github.com/flame-engine/trex-flame) Chrome game in Flame
 - [Bob Box](https://github.com/bluefireteam/bounce_box): which is easy to grasp and a good display of
 our core features.

## What is the difference between Game and FlameGame?

`Game` is the most barebone interface that Flame exposes. If you extend `Game` instead of `FlameGame`
, you will need to implement a lot of things yourself. Flame will hook you up on the game loop, so
you will have to implement `render` and `update` yourself from scratch. If you want to use the
component system, you can, but you don't need to.

`FlameGame` extends `Game` and adds lots of functionality on top of that. Just add your components to
it and it works. They are rendered and updated automatically. You might still want to override some
of `FlameGame`'s methods to add custom functionality, but you will probably be calling the super
method to let `FlameGame` do its work.

## How does the Camera work?

If you are using `FlameGame`, you have a `camera` attribute that allows you to off-set all non-HUD
components by a certain amount. You can add custom logic to your `update` method to have the camera
position be tracked based on the player position, for example, so the player can be always on the
center or on the bottom.

For a more in-depth tutorial on how the camera works (in general & in Flame) and how to use it,
check [erickzanardo](https://github.com/erickzanardo)'s
[excellent tutorial](https://fireslime.xyz/articles/20190911_Basic_Camera_Usage_In_Flame.html),
published via FireSlime.

## How do you handle touch events on your game?

You can always use all the Widgets and features that Flutter already provide, but Flame wraps
the gesture detector callbacks on its base Game class so it can be a little easier to handle those
events, you can find more about it on the input documentation page:

https://flame-engine.org/docs/#/input

## Other questions?

Did you not find what you needed here? Please head to
[FireSlime's Discord channel](https://discord.gg/pxrBmy4) where the community might help you with
any more questions that you might have.
