# Supported Platforms

Flame runs on top of Flutter, so its supported platforms depend on how mature/stable support for each platform is by Flutter.

At the moment, Flame supports both mobile and web.

## Flutter channels

Flame keeps it support on the stable and beta channel, dev and master channel should work, but we don't support them. This mean that issues happening outside stable or beta channel, are not a priority.

## Flame web

To use Flame on web you need to make sure your game is using the CanvasKit/[Skia](https://skia.org/) renderer, this will increase performance on the web as it will use the `canvas` element instead of seperate HTML elements. 

To run your game using skia, use the following command: 

`$ flutter run -d chrome --web-renderer canvaskit`

To build the game for production, using skia, use the following:

`$ flutter build web --release --web-renderer canvaskit`

### Experimental support

Not all Flame APIs might fully support web or are still experimental for the web platform. For example `Flame.device.setOrientation` and `Flame.device.fullScreen` do not work for the web, they can be called, but nothing will happen.

If you are using the `flame_audio` package, then precaching audio will not work on the web. This is due to the fact that the [audioplayers](https://pub.dev/packages/audioplayers) package does not support web. You can work around this problem by using the `http` package. By doing a `GET` request to your audio file. The browser will then cache that request for you.
