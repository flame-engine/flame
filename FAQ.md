# FAQ

This file contains Frequently Asked Questions and their answers. Please feel free to make PRs to amend this file with new questions.

## Any audio/music/sounds related problems

Flame only provides a thin wrapper over the [audioplayers](https://github.com/luanpotter/audioplayers) library. Please make extra sure the problem you are having is with Flame. If you have a low-level or hardware related audio problem, probably it's something related to audioplayers, so please feel free to head to that repository to search your problem or open your issue. If you indeed have a problem with the Flame wrap around audioplayers, please feel free to open an issue.

## Drawing over the notch

In order to draw over the notch, you must add the following line to your ´styles.xml´ file:

´´´xml
<item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
´´´

For more details, please check [this PR](https://github.com/impulse/flutters/commit/25d4ce726cd18e426483e605fe3668ec68b3c12c) from @impulse.

## Other questions?

Didn't find what you needed here? Please head to [FireSlime's Discord channel](https://discord.gg/pxrBmy4) where the community might help you with more questions.