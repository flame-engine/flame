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
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    Iterable<Component>? children,
    int? priority,
  }) : super(
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          children: children,
          priority: priority,
        );

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
