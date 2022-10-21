# Supported Platforms

Since Flame runs on top of Flutter, so its supported platforms depend on which platforms that are
supported by Flutter.

At the moment, Flame supports web, mobile(Android and iOS) and desktop (Windows, MacOS and Linux).


## Flutter channels

Flame keeps it support on the stable channel. The dev, beta and master channel should work, but we
don't support them. This means that issues happening outside the stable channel are not a priority.


## Flame web

To use Flame on web you need to make sure your game is using the CanvasKit/[Skia](https://skia.org/)
renderer. This will increase performance on the web, as it will use the `canvas` element instead of
separate DOM elements.

To run your game using skia, use the following command:

```console
flutter run -d chrome --web-renderer canvaskit
```

To build the game for production, using skia, use the following:

```console
flutter build web --release --web-renderer canvaskit
```


## Deploy your game to GitHub Pages

One easy way to deploy your game online, is to use [GitHub Pages](https://pages.github.com/).
It is a cool feature from GitHub, by which you can easily host web content from your repository.

Here we will explain the easiest way to get your game hosted using GitHub pages.

First thing, lets create the branch where your deployed files will live:

```bash
git checkout -b gh-pages
```

This branch can be created from `main` or any other place, it doesn't matter much. After you push that
branch go back to your `main` branch.

Now you should add the [flutter-gh-pages](https://github.com/bluefireteam/flutter-gh-pages)
action to your repository, you can do that by creating a file `gh-pages.yaml` under the folder
`.github/workflows`.

```yaml
name: Gh-Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - uses: bluefireteam/flutter-gh-pages@v8
        with:
          baseHref: /NAME_OF_YOUR_REPOSITORY/
          webRenderer: canvaskit
```

Be sure to change `NAME_OF_YOUR_REPOSITORY` to the name of your GitHub repository.

Now, whenever you push something to the `main` branch, the action will run and update your
deployed game.

The game should be available at an URL like this:
`https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/`


## Deploy your game to itch.io

1. Create a web build, either from your IDE or by running `flutter build web`
(If it complains about `Missing index.html` run `flutter create . --platforms=web`)
2. Go into `index.html` and remove the line that says `<base href="/">`
3. zip the `build/web` folder and upload to itch.io

**Remember that it shouldn't be the `web` directory in your project's root, but in `build/web`!**

If you are submitting your game to a game jam, remember to make it public and submit it on the
game jam page too (many get confused by this).

Further instructions can be found on
[itch.io](https://itch.io/docs/creators/html5#getting-started/zip-file).


### Web support

When using Flame on the web some methods may not work. For example `Flame.device.setOrientation` and
`Flame.device.fullScreen` won't work on web, they can be called, but nothing will happen.

Another example: pre caching audio using `flame_audio` package also doesn't work due to Audioplayers
not supporting it on web. This can be worked around by using the `http` package, and requesting a
get to the audio file, that will make the browser cache the file producing the same effect as on
mobile.

If you want to create instances of `ui.Image` on the web you can use our
`Flame.images.decodeImageFromPixels` method. This wraps the `decodeImageFromPixels` from the `ui`
library, but with support for the web platform. If the `runAsWeb` argument is set to `true` (by
default it is set to `kIsWeb`) it will decode the image using an internal image method. When the
`runAsWeb` is `false` it will use the `decodeImageFromPixels`, which is currently not supported on
the web.
