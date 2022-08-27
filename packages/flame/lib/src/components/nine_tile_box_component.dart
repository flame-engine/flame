import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/effects/provider_interfaces.dart';
import 'package:meta/meta.dart';

export '../nine_tile_box.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
class NineTileBoxComponent extends PositionComponent implements SizeProvider {
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
  void render(Canvas c) {
    nineTileBox?.drawRect(c, size.toRect());
  }
}
