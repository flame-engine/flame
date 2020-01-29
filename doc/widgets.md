# Widgets

One cool feature when developing games with Flutter is the ability to use Flutter's extensive toolset for building UIs, Flame tries to expand that introducing widgets which are specially made with games in mind.

Here you can find all the available widgets provided by Flame.

You can also see all the widgets showcased inside a [Dashbook](https://github.com/erickzanardo/dashbook) sandbox [here](/doc/examples/widgets)

## Nine Tile Box

A Nine Tile Box is a rectangle drawn using a grid sprite.

The grid sprite is a 3x3 grid and with 9 blocks, representing the 4 courners, the 4 sides and the middle.

The corners are drawn at the same size, the sides are streched on the side direction and the middle is expanded both ways.

The `NineTileBox` widget implements a Container using that standard. This pattern is also implemented in game by the `NineTileBoxComponent` where you can use this same feature, but directly into the game Canvas, to know more about this, check the component docs [here](doc/components.md#nine-tile-box-component).

Here you can find an example of its usage:

```dart
import 'package:flame/widgets/nine_tile_box.dart';

NineTileBox(
        image: image, // dart:ui image instance
        tileSize: 16, // The width/height of the tile on your grid image
        destTileSize: 50, // The dimensions to be used when drawing the tile on the canvas
        child: SomeWidget(), // Any Flutter widget
)
```
