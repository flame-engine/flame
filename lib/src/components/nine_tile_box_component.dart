import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../extensions/vector2.dart';
import '../nine_tile_box.dart';
import 'position_component.dart';

export '../nine_tile_box.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent {
  NineTileBox nineTileBox;

  /// Takes the [NineTileBox] instance used to render this box.
  ///
  /// It uses the x, y, width and height coordinates from the [PositionComponent] to render.
  NineTileBoxComponent(
    this.nineTileBox, {
    Vector2 position,
    Vector2 size,
  }) : super(position: position, size: size);

  @mustCallSuper
  @override
  void render(Canvas c) {
    super.render(c);
    nineTileBox.drawRect(c, size.toRect());
  }
}
