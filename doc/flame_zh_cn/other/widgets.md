# Widgets

使用 Flutter 开发游戏的一个优势是能够利用 Flutter 强大的 UI 构建工具集，Flame 通过引入以游戏为目标的组件来进一步扩展这一点。

在这里，你可以找到 Flame 提供的所有可用组件。

你还可以查看所有组件的展示，见于一...
[Dashbook](https://github.com/bluefireteam/dashbook) sandbox
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widgets)


## NineTileBoxWidget

九宫格框（Nine Tile Box）是一个使用网格精灵绘制的矩形。

网格精灵是一个 3x3 的网格，共有 9 个块，分别代表 4 个角、4 条边和中间部分。

角落部分保持相同大小，边缘部分在侧向上拉伸，而中间部分在两个方向上扩展。

`NineTileBoxWidget` 实现了一个使用该标准的 `Container`。

这种模式也作为组件在 `NineTileBoxComponent` 中实现，以便你可以将此功能直接添加到你的 `FlameGame` 中。

要了解更多信息，请查看组件文档。
[here](../components.md#ninetileboxcomponent).

在这里你可以找到一个如何使用它的示例（不使用 `NineTileBoxComponent`）：

```dart
import 'package:flame/widgets';

NineTileBoxWidget(
    image: image, // dart:ui image instance
    tileSize: 16, // The width/height of the tile on your grid image
    destTileSize: 50, // The dimensions to be used when drawing the tile on the canvas
    child: SomeWidget(), // Any Flutter widget
)
```


## SpriteButton

`SpriteButton` 是一个简单的组件，用于根据 Flame 精灵创建按钮。当你想创建不同于默认样式的按钮时，这个组件非常有用。

例如，当通过图形编辑器绘制按钮的外观比直接在 Flutter 中制作更简单时，它就可以派上用场。

使用方法：

```dart
SpriteButton(
    onPressed: () {
      print('Pressed');
    },
    label: const Text('Sprite Button', style: const TextStyle(color: const Color(0xFF5D275D))),
    sprite: _spriteButton,
    pressedSprite: _pressedSprite,
    height: _height,
    width: _width,
)
```


## SpriteWidget

`SpriteWidget` 是一个用于在组件树中显示 [Sprite](../rendering/images.md#sprite) 的组件。

以下是使用方法：

```dart
SpriteWidget(
    sprite: yourSprite,
    anchor: Anchor.center,
)
```


## SpriteAnimationWidget

`SpriteAnimationWidget` 是一个用于在组件树中显示 [SpriteAnimations](../rendering/images.md#animation) 的组件。

以下是使用方法：

```dart
SpriteAnimationWidget(
    animation: _animation,
    animationTicker: _animationTicker,
    playing: true,
    anchor: Anchor.center,
)
```
