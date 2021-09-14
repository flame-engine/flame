# Widgets

One advantage when developing games with Flutter is the ability to use Flutter's extensive toolset
for building UIs, Flame tries to expand on that by introducing widgets that are made with games in
mind.

Here you can find all the available widgets provided by Flame.

You can also see all the widgets showcased inside a
[Dashbook](https://github.com/erickzanardo/dashbook) sandbox
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widgets)

## Nine Tile Box

A Nine Tile Box is a rectangle drawn using a grid sprite.

The grid sprite is a 3x3 grid and with 9 blocks, representing the 4 corners, the 4 sides and the
middle.

The corners are drawn at the same size, the sides are stretched on the side direction and the middle
is expanded both ways.

The `NineTileBox` widget implements a `Container` using that standard. This pattern is also
implemented as a component in the `NineTileBoxComponent` so that you can add this feature directly
to your `FlameGame`. To get to know more about this, check the component docs
[here](components.md#nine-tile-box-component).

Here you can find an example of how to use it (without using the `NineTileBoxComponent`):

```dart
import 'package:flame/widgets/nine_tile_box.dart';

NineTileBox.asset(
    image: image, // dart:ui image instance
    tileSize: 16, // The width/height of the tile on your grid image
    destTileSize: 50, // The dimensions to be used when drawing the tile on the canvas
    child: SomeWidget(), // Any Flutter widget
)
```

## SpriteButton

`SpriteButton` is a simple widget that creates a button based on Flame sprites. This can be very
useful when trying to create non-default looking buttons. For example when it is easier for you to
achieve your wanted look by drawing the button in a graphics editor, instead of making it directly
in Flutter.

How to use it:

```dart
SpriteButton.asset(
    onPressed: () {
      print('Pressed');
    },
    label: const Text('Sprite Button', style: const TextStyle(color: const Color(0xFF5D275D))),
    sprite: _spriteButton,
    pressedSprite: _pressedSprite,
)
```

## SpriteWidget

`SpriteWidget` is a widget used to display a [Sprite](images.md#sprite) inside a widget
tree.

This is how to use it:

```dart
SpriteWidget.asset(
    sprite: yourSprite,
    anchor: Anchor.center,
)
```

## SpriteAnimationWidget

`SpriteAnimationWidget` is a widget used to display [SpriteAnimations](images.md#animation) inside
a widget tree.

This is how to use it:

```dart
SpriteAnimationWidget.asset(
    animation: _animation,
    playing: true,
    anchor: Anchor.center,
)
```
