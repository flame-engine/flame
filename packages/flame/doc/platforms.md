# Supported Platforms

Flame runs on top of Flutter, so its supported platforms depend on how mature/stable support for each platform is by Flutter.

At the moment, mobile has full support, and we try to keep supporting web the best we can.

## Flutter channels

Flame keeps it support on the stable and beta channel, dev and master channel should work, but we don't support them. This mean that issues happening outside stable or beta channel, are not a priority.

## Flame web

To use Flame on web you need to be on the beta channel of Flutter and the game should be running using [skia](https://skia.org/) rendering, otherwise weird side effects may happen.

To run your game using skia, use the following command:

`$ flutter run -d Chrome --dart-define=FLUTTER_WEB_USE_SKIA=true`

To build the game for production, using skia, use the following:

`$ flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true`

## Experimental support

Support on web, even on the Flame side is still experimental, and some methods may not work, for example `Flame.util.setOrientation` or `Flame.util.fullScreen` don't work on web, they can be called, but nothing will happen.

Another example: pre caching audio using `flame_audio` package also don't work due to Audioplayers not supporting it on web. This can be worked around by using the `http` package, and requesting a get to the audio file, that will make the browser cache the file producing the same effect seem on mobile.
