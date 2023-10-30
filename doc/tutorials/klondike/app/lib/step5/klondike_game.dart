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

  var _klondikeDraw = 1;

  int get klondikeDraw => _klondikeDraw;

  final stock = StockPile(position: Vector2(cardGap, cardGap));
  final waste = WastePile(position: Vector2(cardWidth + 2 * cardGap, cardGap));
  final List<FoundationPile> foundations = [];
  final List<TableauPile> piles = [];
  final List<Card> cards = [];

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    for (int i = 0; i < 4; i++) {
      foundations.add(
        FoundationPile(
          i,
          position: Vector2((i + 3) * (cardWidth + cardGap) + cardGap, cardGap),
        ),
      );
    }
    for (int i = 0; i < 7; i++) {
      piles.add(
        TableauPile(
          position: Vector2(
            cardGap + i * (cardWidth + cardGap),
            cardHeight + 2 * cardGap,
          ),
        ),
      );
    }

    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);

    camera.viewfinder.visibleGameSize =
        Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap);
    camera.viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0);
    camera.viewfinder.anchor = Anchor.topCenter;

    for (var rank = 1; rank <= 13; rank++) {
      for (var suit = 0; suit < 4; suit++) {
        cards.add(Card(rank, suit));
      }
    }
    world.addAll(cards);

    init(Startup.first);
  }

  void init(Startup startType) {
    print('Startup type $startType');
    assert(cards.length == 52, 'There are ${cards.length}: should be 52.');
    if (startType == Startup.first) {
      deal(Startup.first);
    } else {
      stock.init();
      waste.init();
      foundations.forEach((foundation) => foundation.init());
      piles.forEach((tableau) => tableau.init());
      cards.forEach((card) => card.init());

      var nMovingCards = 0;
      for (Card card in cards) {
        if (card.isFaceUp) card.flip();
        if ((card.position - stock.position).length > 1.0) {
          // Move cards that are not already in the Stock Pile.
          nMovingCards++;
          card.doMove(
            stock.position,
            onComplete: () {
              nMovingCards--;
              if (nMovingCards == 0) deal(startType);
              else print('$nMovingCards cards still moving');
            }
          );
        }
      }
      print('$nMovingCards CARDS ARE NOW MOVING...');
    }
  }

  void deal(Startup startType) {
    print('NCards ${cards.length}, cards $cards');

    switch(startType) {
      case Startup.first:
      case Startup.newDeal:
        print('Shuffle $startType ...');
        cards.shuffle();
        break;
      case Startup.changeDraw:
        _klondikeDraw = (_klondikeDraw == 3) ? 1 : 3;
        print('Change to Draw $_klondikeDraw and shuffle...');
        cards.shuffle();
        break;
      case Startup.sameDeal:
      default:
        print('Replay same deal as before...');
        break;
    }

    print('Deal...');
    var cardToDeal = cards.length - 1;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards[cardToDeal--]);
      }
      piles[i].flipTopCard();
    }
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
    print('NCards ${cards.length}, cards $cards');
  }
}

enum Startup {first, newDeal, sameDeal, changeDraw}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
