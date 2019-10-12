# FAQ

This file contains Frequently Asked Questions and their answers. Please feel free to make PRs to amend this file with new questions.

## Any audio/music/sounds related problems

Flame only provides a thin wrapper over the [audioplayers](https://github.com/luanpotter/audioplayers) library. Please make extra sure the problem you are having is with Flame. If you have a low-level or hardware related audio problem, probably it's something related to audioplayers, so please feel free to head to that repository to search your problem or open your issue. If you indeed have a problem with the Flame wrap around audioplayers, then open an issue here.

## Drawing over the notch (for Android)

In order to draw over the notch, you must add the following line to your `styles.xml` file:

```xml
<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
```

For more details, please check [this PR](https://github.com/impulse/flutters/commit/25d4ce726cd18e426483e605fe3668ec68b3c12c) from [impulse](https://github.com/impulse).

## Examples

We have a few examples! The simplest of all is in [the root example folder](/example/). This folder must be called `example` and contain a single project, so it's a very simple generic example game.

However there is an [examples folder inside the docs](/doc/examples) that contains many more examples. Most newer features we are adding we are trying to add a specific example for that. Those are directed to specific features.

If you want a more full-fledged game, please check [BGUG](https://github.com/fireslime/bgug), FireSlime's open source fast paced side-scrolling platformer. It is mostly up-to-date with Flame and uses a good chunck of the featues offered by the engine. Other examples game are [feroult](https://github.com/feroult)'s [Haunt](https://github.com/feroult/haunt), which is outdated but showcases Box2D,[renancaraujo](https://github.com/renancaraujo)'s port of the [trex](https://github.com/flame-engine/trex-flame) chrome game in Flame, and also [Bob Box](https://github.com/fireslime/bounce_box), which is easy to grasp and a good display of our core features.

## What is the difference between Game and BaseGame?

`Game` is the most barebones interface that Flame exposes. If you crete a Game, you will need to implement a lot of stuff. Flame will hook you up on the game loop, so you will get to implement `render` and `update` yourself. From scratch. If you wanna use the component system, you can, but you don't need to. You do everything yourself.

`BaseGame` extends `Game` and adds lots of functionality on top of that. Just drop your components, it works! They are rendered, updated, resized, automatically. You might still want to override some of `BaseGame`'s methods to add custom functionality, but you will probably be calling the super method to let `BaseGame` do its work.

## How does the Camera work?

If you are using `BaseGame`, you have a `camera` attribute that allows you to off-set all non-HUD components by a certain amount. You can add custom logic to your `update` method to have the camera position be tracked based on the player position, for example, so the player can be always on the center or on the bottom.

For a more in-depth tutorial on how the camera works (in general & in Flame) and how to use it, check [erickzanardo](https://github.com/erickzanardo)'s [excellent tutorial](https://fireslime.xyz/articles/20190911_Basic_Camera_Usage_In_Flame.html), published via FireSlime.

## Other questions?

Didn't find what you needed here? Please head to [FireSlime's Discord channel](https://discord.gg/pxrBmy4) where the community might help you with more questions.