import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/nine_tile_box.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent {
  NineTileBox nineTileBox;

  /// Takes the [NineTileBox] instance used to render this box.
  ///
  /// It uses the x, y, width and height coordinates from the [PositionComponent] to render.
  NineTileBoxComponent(this.nineTileBox);

  @override
  void render(Canvas c) {
    nineTileBox.drawRect(c, toRect());
  }
}
