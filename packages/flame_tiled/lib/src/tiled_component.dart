import 'dart:ui';

import 'package:flame/components.dart';

import 'tiled.dart';

class TiledComponent extends Component {
  RenderableTiledMap renderableTiledMap;

  TiledComponent(this.renderableTiledMap);

  @override
  void render(Canvas canvas) {
    renderableTiledMap.render(canvas);
  }

  static Future<TiledComponent> load(
    String fileName,
    Vector2 destTileSize,
  ) async {
    return TiledComponent(
      await RenderableTiledMap.parse(fileName, destTileSize),
    );
  }
}
