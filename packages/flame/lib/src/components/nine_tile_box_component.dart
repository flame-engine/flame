import 'dart:ui';

import 'package:flame/components.dart';
import 'package:meta/meta.dart';

export '../nine_tile_box.dart';

/// This class is a thin wrapper on top of [NineTileBox] as a component.
///
/// Takes the [NineTileBox] instance to render a box that can grow and shrink
/// seamlessly.
///
/// It uses the x, y, width and height coordinates from the
/// [PositionComponent] to render.
class NineTileBoxComponent({
  var NineTileBox? _nineTileBox,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
}) extends PositionComponent with HasPaint, ImageRetainer {
  /// The [NineTileBox] that this component renders.
  NineTileBox? get nineTileBox => _nineTileBox;

  set nineTileBox(NineTileBox? value) {
    _nineTileBox = value;
    updateRetainedImages();
  }

  @override
  Iterable<Image> get retainedImages {
    final nineTileBox = _nineTileBox;
    return nineTileBox == null ? const [] : [nineTileBox.sprite.image];
  }

  @override
  @mustCallSuper
  void onMount() {
    assert(
      nineTileBox != null,
      'The nineTileBox should be set either in the constructor or in onLoad',
    );
    super.onMount();
  }

  @mustCallSuper
  @override
  void render(Canvas canvas) {
    nineTileBox?.drawRect(canvas, size.toRect(), paint);
  }
}
