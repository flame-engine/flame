import 'dart:ui';

import '../nine_tile_box.dart';
import 'position_component.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent {
  NineTileBox nineTileBox;

  /// Takes the [NineTileBox] instance used to render this box.
  ///
  /// It uses the x, y, width and height coordinates from the [PositionComponent] to render.
  NineTileBoxComponent(this.nineTileBox);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    nineTileBox.drawRect(canvas, Rect.fromLTWH(0.0, 0.0, width, height));
  }
}
