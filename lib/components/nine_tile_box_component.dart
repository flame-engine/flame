import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../nine_tile_box.dart';
import 'position_component.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent {
  NineTileBox nineTileBox;

  /// Takes the [NineTileBox] instance used to render this box.
  ///
  /// It uses the x, y, width and height coordinates from the [PositionComponent] to render.
  NineTileBoxComponent(this.nineTileBox);

  @mustCallSuper
  @override
  void render(Canvas c) {
    super.render(c);
    nineTileBox.drawRect(c, toZeroRect());
  }
}
