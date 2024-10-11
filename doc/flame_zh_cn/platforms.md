# Supported Platforms

由于 Flame 是在 Flutter 之上运行的，所以它支持的平台取决于 Flutter 支持的平台。

目前，Flame 支持 web、移动（Android 和 iOS）以及桌面（Windows、MacOS 和 Linux）平台。


## Flutter channels

Flame 保持其对稳定频道的支持。开发、测试和主频道应该可以工作，但我们不提供支持。这意味着在稳定频道之外发生的问题不是优先考虑的。


## Flame web

要在使用 Web 平台的 Flame，你需要确保你的游戏使用的是 CanvasKit/[Skia](https://skia.org/) 渲染器。这将提升在 Web 上的性能，因为它将使用 `canvas` 元素而不是独立的 DOM 元素。

要使用 Skia 运行你的游戏，请使用以下命令：

```shell
flutter run -d chrome --web-renderer canvaskit
```

为了构建生产版本的游戏，使用下面的命令:

```shell
flutter build web --release --web-renderer canvaskit
```


## Deploy your game to GitHub Pages

一个将你的游戏在线部署的简单方法是使用 [GitHub Pages](https://pages.github.com/)。
它是 GitHub 的一个很酷的特性，通过它你可以轻松地从你的仓库托管 Web 内容。

这里我们将解释使用 GitHub 页面托管你的游戏的最简单方法。

首先，让我们创建一个分支，你的部署文件将存放在这里：

```shell
git checkout -b gh-pages
```

这个分支可以从 `main` 或任何其他地方创建，这并不重要。在你推送了那个分支后，返回到你的 `main` 分支。

现在你应该为你的仓库添加 [flutter-gh-pages](https://github.com/bluefireteam/flutter-gh-pages) 动作，你可以通过在 `.github/workflows` 文件夹下创建一个 `gh-pages.yaml` 文件来实现。

```yaml
name: Gh-Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: bluefireteam/flutter-gh-pages@v8
        with:
          baseHref: /NAME_OF_YOUR_REPOSITORY/
          webRenderer: canvaskit
```

确保将 `NAME_OF_YOUR_REPOSITORY` 替换为你的 GitHub 仓库名称。

现在，每当你向 `main` 分支推送内容时，该动作将运行并更新你部署的游戏。

游戏应该可以在类似这样的 URL 访问：
`https://YOUR_GITHUB_USERNAME.github.io/YOUR_REPO_NAME/`


## Deploy your game to itch.io

1. 创建一个 web 构建，可以通过你的 IDE 或运行 `flutter build web` 来完成。
   （如果出现 `Missing index.html` 的错误，运行 `flutter create . --platforms=web`）

2. 打开 `index.html` 文件，删除 `<base href="/">` 这一行。

3. 将 `build/web` 文件夹压缩为 ZIP 文件并上传到 itch.io。

**记住，这应该是你项目根目录下的 `build/web`，而不是 `web` 目录！**

如果你正在将游戏提交到游戏开发比赛，请记得将其设为公开，并在比赛页面上提交（许多人对此感到困惑）。

进一步的说明可以在 [itch.io](https://itch.io/docs/creators/html5#getting-started/zip-file) 找到。


### Web support


当在 web 上使用 Flame 时，一些方法可能无法工作。

例如 `Flame.device.setOrientation` 和 `Flame.device.fullScreen` 在 web 上不会工作，它们可以被调用，但不会有任何反应。

另一个例子：使用 `flame_audio` 包预缓存音频也无法工作，因为 Audioplayers 在 web 上不支持。

这个问题可以通过使用 `http` 包，并请求一个音频文件的 GET 请求来解决，这将使浏览器缓存该文件，产生与在移动设备上相同的效果。

如果你想在 web 上创建 `ui.Image` 的实例，你可以使用我们的 `Flame.images.decodeImageFromPixels` 方法。

这个方法包装了 `ui` 库中的 `decodeImageFromPixels`，但增加了对 web 平台的支持。如果 `runAsWeb` 参数设置为 `true`（默认设置为 `kIsWeb`），它将使用内部图像方法解码图像。

当 `runAsWeb` 设置为 `false` 时，它将使用 `decodeImageFromPixels`，这在 web 上目前是不支持的。
