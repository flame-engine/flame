# Images

要开始，你必须有一个合适的文件夹结构，并将文件添加到 `pubspec.yaml` 文件中，如下所示：

```yaml
flutter:
  assets:
    - assets/images/player.png
    - assets/images/enemy.png
```

图像可以是 Flutter 支持的任何格式，包括：JPEG、WebP、PNG、GIF、动画 GIF、动画 WebP、BMP 和 WBMP。其他格式需要额外的库。例如，SVG 图像可以通过 `flame_svg` 库加载。


## Loading images

Flame 提供了一个实用工具类 `Images`，它允许你轻松地从资源目录加载和缓存图像到内存中。

Flutter 有几种与图像相关的类型，将所有内容正确地从本地资源转换为可以在 Canvas 上绘制的 `Image` 有点复杂。这个类允许你获取一个可以在 `Canvas` 上使用 `drawImageRect` 方法绘制的 `Image`。

它会自动缓存通过文件名加载的任何图像，因此你可以安全地多次调用它。

加载和清除缓存的方法有：`load`、`loadAll`、`clear` 和 `clearCache`。它们返回加载图像的 `Future`。在图像以任何方式使用之前，必须等待这些未来的完成。如果你不想立即等待这些未来，你可以启动多个 `load()` 操作，然后使用 `Images.ready()` 方法一次性等待它们全部完成。

要同步检索先前缓存的图像，可以使用 `fromCache` 方法。如果之前没有加载过该键的图像，它将抛出一个异常。

要将已经加载的图像添加到缓存中，可以使用 `add` 方法，并设置图像在缓存中应该具有的键。你可以使用 `keys` getter 检索缓存中的所有键。

你还可以使用 `ImageExtension.fromPixels()` 在游戏中动态创建图像。

对于 `clear` 和 `clearCache`，请注意，从缓存中移除的每个图像都会调用 `dispose`，因此请确保之后不再使用该图像。


### Standalone usage

可以通过实例化手动使用它：

```dart
import 'package:flame/cache.dart';
final imagesLoader = Images();
Image image = await imagesLoader.load('yourImage.png');
```

但 Flame 还提供了两种无需自行实例化即可使用这个类的方法。


### Flame.images

Flame 类提供了一个单例，可以用作全局图像缓存。

示例：

```dart
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

// inside an async context
Image image = await Flame.images.load('player.png');

final playerSprite = Sprite(image);
```


### Game.images

`Game` 类也提供了一些用于处理图像加载的实用工具方法。它内置了一个 `Images` 类的实例，可以用来加载游戏中使用的图像资源。当游戏组件从组件树中移除时，游戏将自动释放缓存。

`Game` 类的 `onLoad` 方法是加载初始资源的绝佳位置。

示例：

```dart
class MyGame extends Game {

  Sprite player;

  @override
  Future<void> onLoad() async {
    // Note that you could also use Sprite.load for this.
    final playerImage = await images.load('player.png');
    player = Sprite(playerImage);
  }
}
```

在游戏运行时，也可以通过 `images.fromCache` 检索已加载的资源，例如：

```dart
class MyGame extends Game {

  // attributes omitted

  @override
  Future<void> onLoad() async {
    // other loads omitted
    await images.load('bullet.png');
  }

  void shoot() {
    // This is just an example, in your game you probably don't want to
    // instantiate new [Sprite] objects every time you shoot.
    final bulletSprite = Sprite(images.fromCache('bullet.png'));
    _bullets.add(bulletSprite);
  }
}
```


## Loading images over the network

Flame 核心包没有提供从网络加载图像的内置方法。

原因是 Flutter/Dart 没有内置的 HTTP 客户端，这需要使用某个包，并且由于市面上有多个可用的包，我们不想强迫用户使用特定的包。

话虽如此，一旦用户选择了一个 HTTP 客户端包，从网络加载图像就非常简单了。以下代码片段展示了如何使用 [http](https://pub.dev/packages/http) 包从网络获取 `Image`。

```dart
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';

final response = await http.get('https://url.com/image.png');
final image = await decodeImageFromList(response.bytes);
```

```{note}
请查看 [`flame_network_assets`](https://pub.dev/packages/flame_network_assets)，它是一个现成的网络资源解决方案，提供了内置的缓存功能。
```


## Sprite

Flame 提供了一个 `Sprite` 类，代表一张图片或图片的一部分。

你可以通过提供一张 `Image` 以及定义该精灵所代表的图片区域的坐标来创建一个 `Sprite`。

例如，这将创建一个代表所传递文件整个图片的精灵：

```dart
final image = await images.load('player.png');
Sprite player = Sprite(image);
```

你还可以指定精灵在原始图片中的坐标。这允许你使用精灵表并减少内存中的图片数量，例如：

```dart
final image = await images.load('player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);
```

`srcPosition` 的默认值是 `(0.0, 0.0)`，而 `srcSize` 的默认值是 `null`（意味着它将使用源图像的完整宽度/高度）。

`Sprite` 类有一个渲染方法，允许你将精灵渲染到 `Canvas` 上：

```dart
final image = await images.load('block.png');
Sprite block = Sprite(image);

// in your render method
block.render(canvas, 16.0, 16.0); //canvas, width, height
```

你必须将大小传递给渲染方法，图片将相应地调整大小。

`Sprite` 类的所有渲染方法都可以接收一个 `Paint` 实例作为可选的命名参数 `overridePaint`，该参数将覆盖当前 `Sprite` 的绘制实例，仅用于那次渲染调用。

`Sprite` 也可以作为组件使用，只需使用 `SpriteWidget` 类即可。
这里有一个完整的[使用精灵作为组件的示例](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_widget_example.dart)。


## SpriteBatch

如果你有一个精灵表（也称为图像图集，即包含较小图像的图像），并且想要有效地渲染它 - `SpriteBatch` 可以为你处理这项工作。

提供图像的文件名，然后添加描述图像不同部分的矩形，以及变换（位置、缩放和旋转）和可选颜色。

你可以使用 `Canvas` 和可选的 `Paint`、`BlendMode` 和 `CullRect` 来渲染它。

为了方便，还提供了 `SpriteBatchComponent`。

请参见[如何使用它](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprite_batch/sprite_batch_example.dart)。


## ImageComposition

在某些情况下，你可能想要将多个图像合并成单个图像；这被称为[合成](https://en.wikipedia.org/wiki/Compositing)。例如，在处理[SpriteBatch](#spritebatch) API以优化绘制调用时，这可能非常有用。

对于这类用例，Flame 提供了 `ImageComposition` 类。这允许你将多个图像，每个都放置在它们自己的位置，添加到一个新的图像上：

```dart
final composition = ImageComposition()
  ..add(image1, Vector2(0, 0))
  ..add(image2, Vector2(64, 0));
  ..add(image3,
    Vector2(128, 0),
    source: Rect.fromLTWH(32, 32, 64, 64),
  );
  
Image image = await composition.compose();
Image imageSync = composition.composeSync();
```

如你所见，有两种版本的合成图像可用。使用 `ImageComposition.compose()` 进行异步处理。或者使用新的 `ImageComposition.composeSync()` 函数，利用 `Picture.toImageSync` 函数的优势，将图像光栅化到 GPU 上下文中。

**注意：** 合成图像是昂贵的操作，我们不推荐你每次都执行它，因为它会严重影响性能。相反，我们建议预先渲染你的合成图像，这样你就可以重用输出的图像。


## Animation

`Animation` 类帮助你创建一个循环的精灵动画。

你可以通过传递一个等大小精灵的列表和步长时间（即，移动到下一帧所需的秒数）来创建它：

```dart
final a = SpriteAnimationTicker(SpriteAnimation.spriteList(sprites, stepTime: 0.02));
```

创建动画后，你需要调用它的 `update` 方法并在游戏实例上渲染当前帧的精灵。

示例：

```dart
class MyGame extends Game {
  SpriteAnimationTicker a;

  MyGame() {
    a = SpriteAnimationTicker(SpriteAnimation(...));
  }

  void update(double dt) {
    a.update(dt);
  }

  void render(Canvas c) {
    a.getSprite().render(c);
  }
}
```

生成精灵列表的一个更好替代方法是使用 `fromFrameData` 构造函数：

```dart
const amountOfFrames = 8;
final a = SpriteAnimation.fromFrameData(
    imageInstance,
    SpriteAnimationFrame.sequenced(
      amount: amountOfFrames,
      textureSize: Vector2(16.0, 16.0),
      stepTime: 0.1,
    ),
);
```

当使用精灵表时，这个构造函数使得创建 `Animation` 变得非常容易。

在构造函数中，你传递一个图像实例和帧数据，其中包含一些可以用来描述动画的参数。请查看 `SpriteAnimationFrameData` 类上可用的构造函数的文档，以了解所有参数。

如果你使用 Aseprite 进行动画制作，Flame 提供了一些对 Aseprite 动画的 JSON 数据的支持。要使用这个特性，你需要导出精灵表的 JSON 数据，并使用如下代码片段：

```dart
final image = await images.load('chopper.png');
final jsonData = await assets.readJson('chopper.json');
final animation = SpriteAnimation.fromAsepriteData(image, jsonData);
```

**注意：** Flame 不支持修剪过的精灵表，所以如果你以这种方式导出你的精灵表，它将具有修剪后的尺寸，而不是精灵的原始尺寸。

创建后的动画具有更新和渲染方法；后者渲染当前帧，前者则推进内部时钟以更新帧。

动画通常用在 `SpriteAnimationComponent` 中，但也可以创建包含多个动画的自定义组件。

要了解更多信息，可以查看[将动画作为组件使用](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_animation_widget_example.dart)的完整示例代码。


## SpriteSheet

精灵表是包含同一精灵多个帧的大图像，是组织和存储动画的非常好的方式。Flame 提供了一个非常简单的实用工具类来处理精灵表，使用它你可以加载你的精灵表图像并从中提取动画。以下是一个如何使用它的简单示例：

```dart
import 'package:flame/sprite.dart';

final spriteSheet = SpriteSheet(
  image: imageInstance,
  srcSize: Vector2.all(16.0),
);

final animation = spriteSheet.createAnimation(0, stepTime: 0.1);
```

现在你可以直接使用这个动画，或者在一个动画组件中使用它。

你还可以通过使用 `SpriteSheet.createFrameData` 或 `SpriteSheet.createFrameDataFromId` 来检索单个 `SpriteAnimationFrameData` 来创建自定义动画：

```dart
final animation = SpriteAnimation.fromFrameData(
  imageInstance, 
  SpriteAnimationData([
    spriteSheet.createFrameDataFromId(1, stepTime: 0.1), // by id
    spriteSheet.createFrameData(2, 3, stepTime: 0.3), // row, column
    spriteSheet.createFrameDataFromId(4, stepTime: 0.1), // by id
  ]),
);
```

如果你不需要任何形式的动画，而只是想在 `SpriteSheet` 上获得一个 `Sprite` 实例，你可以使用 `getSprite` 或 `getSpriteById` 方法：

```dart
spriteSheet.getSpriteById(2); // by id
spriteSheet.getSprite(0, 0); // row, column
```

查看 [`SpriteSheet` 类](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprites/sprite_sheet_example.dart) 的完整示例，以了解更多关于如何使用它的详细信息。
