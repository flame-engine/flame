# Supported Platforms

Flame runs on top of Flutter, so its supported platforms depend on how mature/stable support for
each platform is by Flutter.

At the moment, Flame supports both mobile and web.

## Flutter channels

Flame keeps it support on the stable channel. The dev, beta and master channel should work, but we
don't support them. This means that issues happening outside the stable channel are not a priority.

## Flame web

To use Flame on web you need to make sure your game is using the CanvasKit/[Skia](https://skia.org/)
renderer, this will increase performance on the web as it will use the `canvas` element instead of
seperate HTML elements. 

To run your game using skia, use the following command: 

`$ flutter run -d chrome --web-renderer canvaskit`

To build the game for production, using skia, use the following:

`$ flutter build web --release --web-renderer canvaskit`

### Web support

When using Flame on the web some methods may not work. For example `Flame.util.setOrientation` and
`Flame.util.fullScreen` won't work on web, they can be called, but nothing will happen.

Another example: pre caching audio using `flame_audio` package also doesn't work due to Audioplayers
not supporting it on web. This can be worked around by using the `http` package, and requesting a
get to the audio file, that will make the browser cache the file producing the same effect as on
mobile.

If you want to create instances of `ui.Image` on the web you can use our
`Flame.images.decodeImageFromPixels` method. This wraps the `decodeImageFromPixels` from the `ui`
library, but with support for the web platform. If the `runAsWeb` argument is set to `true` (by
default it is set to `kIsWeb`) it will decode the image using a internal image method. When the
`runAsWeb` is `false` it will use the `decodeImageFromPixels`, which is currently not supported on
the web.
