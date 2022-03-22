import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';

import 'components/foundation.dart';
import 'components/pile.dart';
import 'components/stock.dart';
import 'components/waste.dart';

class KlondikeGame extends FlameGame {
  final double gap = 175.0;
  final double w = 1000.0;
  final double h = 1400.0;

  @override
  Future<void> onLoad() async {
    await images.load('klondike-sprites.png');

    final stock = Stock()
      ..size = Vector2(w, h)
      ..position = Vector2(gap, gap);
    final waste = Waste()
      ..size = Vector2(w * 1.5, h)
      ..position = Vector2(w + 2 * gap, gap);
    final foundations = [
      for (var i = 0; i < 4; i++)
        Foundation()
          ..size = Vector2(w, h)
          ..position = Vector2((i + 3) * (w + gap) + gap, gap)
    ];
    final piles = [
      for (var i = 0; i < 7; i++)
        Pile()
          ..size = Vector2(w, h)
          ..position = Vector2(gap + i * (w + gap), h + 2 * gap)
    ];

    final world = World()..addToParent(this);
    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize = Vector2(w * 7 + gap * 8, 4 * h + 3 * gap)
      ..viewfinder.position = Vector2(w * 3.5 + gap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera);
  }
}
