import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class GroupLayer extends RenderableLayer<Group> {
  GroupLayer({
    required super.layer,
    required super.map,
    required super.destTileSize,
    super.filterQuality,
  });

  /// The layers of this group, in the order they are rendered.
  Iterable<RenderableLayer> get layers => children.whereType<RenderableLayer>();

  @override
  void refreshCache() {
    for (final child in layers) {
      child.refreshCache();
    }
  }

  @override
  void onOpacityChanged() {
    for (final child in layers) {
      child.onOpacityChanged();
    }
  }

  @override
  void updateView(Vector2 viewCenter, Rect visibleRect) {
    super.updateView(viewCenter, visibleRect);
    for (final child in layers) {
      child.updateView(viewCenter, this.visibleRect);
    }
  }
}
