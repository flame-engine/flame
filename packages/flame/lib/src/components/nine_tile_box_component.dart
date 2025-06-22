import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

export '../nine_tile_box.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent with HasPaint {
  NineTileBox? nineTileBox;

  /// Takes the [NineTileBox] instance to render a box that can grow and shrink
  /// seamlessly.
  ///
  /// It uses the x, y, width and height coordinates from the
  /// [PositionComponent] to render.
  NineTileBoxComponent({
    this.nineTileBox,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  @mustCallSuper
  void onMount() {
    assert(
      nineTileBox != null,
      'The nineTileBox should be set either in the constructor or in onLoad',
    );
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    nineTileBox?.drawRect(canvas, size.toRect(), paint);
  }
}
