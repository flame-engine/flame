import 'dart:ui';

import 'component.dart';
import 'position_component.dart';
import '../nine_tile_box.dart';

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
