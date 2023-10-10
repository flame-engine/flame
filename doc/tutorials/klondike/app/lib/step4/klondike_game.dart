import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/card.dart';
import 'components/foundation_pile.dart';
import 'components/stock_pile.dart';
import 'components/tableau_pile.dart';
import 'components/waste_pile.dart';

class KlondikeGame extends FlameGame {
  static const double cardGap = 175.0;
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  // Note: Since Flame 1.9.0, world and camera are defined in FlameGame.
  KlondikeGame()
    : super(camera: CameraComponent()
        ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
        ..viewfinder.anchor = Anchor.topCenter
      );

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    final stock = StockPile(position: Vector2(cardGap, cardGap));
    final waste =
        WastePile(position: Vector2(cardWidth + 2 * cardGap, cardGap));
    final foundations = List.generate(
      4,
      (i) => FoundationPile(
        i,
        position: Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
      ),
    );
    final piles = List.generate(
      7,
      (i) => TableauPile(
        position: Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
      ),
    );

    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);

    camera.viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap);

    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++) Card(rank, suit),
    ];
    cards.shuffle();
    world.addAll(cards);

    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards.removeLast());
      }
      piles[i].flipTopCard();
    }
    cards.forEach(stock.acquireCard);
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
