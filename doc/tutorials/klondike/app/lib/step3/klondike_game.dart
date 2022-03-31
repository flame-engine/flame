import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/card.dart';
import 'components/foundation.dart';
import 'components/pile.dart';
import 'components/stock.dart';
import 'components/waste.dart';
import 'rank.dart';
import 'suit.dart';

class KlondikeGame extends FlameGame {
  static double cardGap = 175.0;
  static double cardWidth = 1000.0;
  static double cardHeight = 1400.0;
  static double cardRadius = 100.0;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    final stock = Stock()
      ..size = Vector2(cardWidth, cardHeight)
      ..position = Vector2(cardGap, cardGap);
    final waste = Waste()
      ..size = Vector2(cardWidth * 1.5, cardHeight)
      ..position = Vector2(cardWidth + 2 * cardGap, cardGap);
    final foundations = List.generate(
      4,
      (i) => Foundation()
        ..size = Vector2(cardWidth, cardHeight)
        ..position =
            Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
    );
    final piles = List.generate(
      7,
      (i) => Pile()
        ..size = Vector2(cardWidth, cardHeight)
        ..position = Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
    );

    final world = World()
      ..add(stock)
      ..add(waste)
      ..addAll(foundations)
      ..addAll(piles);
    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;

    add(world);
    add(camera);

    Card(Rank.fromInt(2), Suit.fromInt(0))
      ..position = Vector2(2000, 1300)
      ..addToParent(world);
  }
}
