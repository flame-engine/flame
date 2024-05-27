import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

class IsometricTileMapExample extends FlameGame with MouseMovementDetector {
  static const String description = '''
    Shows an example of how to use the `IsometricTileMapComponent`.\n\n
    Move the mouse over the board to see a selector appearing on the tiles.
  ''';

  final topLeft = Vector2.all(500);

  static const scale = 2.0;
  static const srcTileSize = 32.0;
  static const destTileSize = scale * srcTileSize;

  final originColor = Paint()..color = const Color(0xFFFF00FF);
  final originColor2 = Paint()..color = const Color(0xFFAA55FF);

  final bool halfSize;
  late final tileHeight = scale * (halfSize ? 8.0 : 16.0);
  late final suffix = halfSize ? '-short' : '';

  late IsometricTileMapComponent base;
  late Selector selector;

  IsometricTileMapExample({required this.halfSize});

  @override
  Future<void> onLoad() async {
    final tilesetImage = await images.load('tile_maps/tiles$suffix.png');
    final tileset = SpriteSheet(
      image: tilesetImage,
      srcSize: Vector2.all(srcTileSize),
    );
    final matrix = [
      [3, 1, 1, 1, 0, 0],
      [-1, 1, 2, 1, 0, 0],
      [-1, 0, 1, 1, 0, 0],
      [-1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 0, 2],
      [1, 3, 3, 3, 0, 2],
    ];
    add(
      base = IsometricTileMapComponent(
        tileset,
        matrix,
        destTileSize: Vector2.all(destTileSize),
        tileHeight: tileHeight,
        position: topLeft,
      ),
    );

    final selectorImage = await images.load('tile_maps/selector$suffix.png');
    add(selector = Selector(destTileSize, selectorImage));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.renderPoint(topLeft, size: 5, paint: originColor);
    canvas.renderPoint(
      base.position + base.getBlockCenterPosition(const Block(0, 0)),
      size: 5,
      paint: originColor2,
    );
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.widget;
    final block = base.getBlock(screenPosition);
    selector.show = base.containsBlock(block);
    selector.position.setFrom(topLeft + base.getBlockRenderPosition(block));
  }
}

class Selector extends SpriteComponent {
  bool show = true;

  Selector(double s, Image image)
      : super(
          sprite: Sprite(image, srcSize: Vector2.all(32.0)),
          size: Vector2.all(s),
        );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}
