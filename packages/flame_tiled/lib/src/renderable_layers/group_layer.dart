import 'package:flame/extensions.dart';
import 'package:flame_tiled/src/renderable_layers/renderable_layer.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';

@internal
class GroupLayer extends RenderableLayer<Group> {
  GroupLayer({
    required super.layer,
    required super.parent,
    required super.camera,
    required super.map,
    required super.destTileSize,
    super.filterQuality,
  });

  @override
  void refreshCache() {
    final sublayers = children.whereType<RenderableLayer>();
    for (final sub in sublayers) {
      sub.refreshCache();
    }
  }
}
