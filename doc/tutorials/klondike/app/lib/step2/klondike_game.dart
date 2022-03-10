import 'package:flame/game.dart';
import 'package:flame/experimental.dart';

import 'components/foundation.dart';
import 'components/pile.dart';
import 'components/stock.dart';
import 'components/waste.dart';

class KlondikeGame extends FlameGame {
  late final Stock stock;
  late final Waste waste;
  late final List<Foundation> foundations;
  late final List<Pile> piles;

  @override
  Future<void> onLoad() async {
    await images.load('klondike-sprites.png');
    final world = World()..addToParent(this);
    CameraComponent(world: world)
      ..viewfinder.visibleGameSize = Vector2(8000, 6000)
      ..viewfinder.position = Vector2(300, 300) // FIXME
      ..addToParent(this);

    stock = Stock()
      ..size = Vector2(1000, 1400)
      ..position = Vector2(125, 125)
      ..debugPaint.strokeWidth = 0
      ..addToParent(world);
    waste = Waste()
      ..size = Vector2(1500, 1400)
      ..position = Vector2(1250, 125)
      ..debugPaint.strokeWidth = 0
      ..addToParent(world);
    foundations = [
      for (var i = 0; i < 4; i++)
        Foundation()
          ..size = Vector2(1000, 1400)
          ..position = Vector2(3500 + i * 1125, 125)
          ..debugPaint.strokeWidth = 0
          ..addToParent(world)
    ];
    piles = [
      for (var i = 0; i < 7; i++)
        Pile()
          ..size = Vector2(1000, 1400)
          ..position = Vector2(125 + i * 1125, 1650)
          ..debugPaint.strokeWidth = 0
          ..addToParent(world)
    ];
  }
}
