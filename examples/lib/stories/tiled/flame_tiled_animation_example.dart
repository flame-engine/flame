import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

class FlameTiledAnimationExample extends FlameGame {
  static const String description = '''
    Loads and displays an animated Tiled map.
  ''';

  late final TiledComponent map;

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load('dungeon.tmx', Vector2.all(32));
    add(map);
  }
}
