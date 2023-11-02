import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/card.dart';
import 'components/foundation_pile.dart';
import 'components/stock_pile.dart';
import 'components/tableau_pile.dart';
import 'components/waste_pile.dart';
import 'components/flat_button.dart';

enum Startup {first, newDeal, sameDeal, changeDraw, haveFun}

class KlondikeGame extends FlameGame {

  static const double cardGap = 175.0;
  static const double topGap = 500.0;
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardRadius = 100.0;
  static const double cardSpaceWidth = cardWidth + cardGap;
  static const double cardSpaceHeight = cardHeight + cardGap;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  // Default is Klondike Draw 1: a button switches between Draw 1 and Draw 3.
  var _klondikeDraw = 1;

  int get klondikeDraw => _klondikeDraw;

  final stock = StockPile(position: Vector2(cardGap, topGap));
  final waste = WastePile(position: Vector2(cardSpaceWidth + cardGap, topGap));
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
          position: Vector2(
            (i + 3) * cardSpaceWidth + cardGap,
            topGap),
        ),
      );
    }
    for (int i = 0; i < 7; i++) {
      piles.add(
        TableauPile(
          position: Vector2(
            i * cardSpaceWidth + cardGap,
            cardSpaceHeight + topGap,
          ),
        ),
      );
    }

    for (var rank = 1; rank <= 13; rank++) {
      for (var suit = 0; suit < 4; suit++) {
        cards.add(Card(rank, suit));
      }
    }

    final gameSize = Vector2(
            7 * cardSpaceWidth + cardGap,
            4 * cardSpaceHeight + topGap);
    final gameMidX = gameSize.x / 2;

    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);
    world.addAll(cards);

    addButton('New deal',   gameMidX,                      Startup.newDeal);
    addButton('Same deal',  gameMidX + cardSpaceWidth,     Startup.sameDeal);
    addButton('Draw 1 ⇌ 3', gameMidX + 2 * cardSpaceWidth, Startup.changeDraw);
    addButton('Have fun',   gameMidX + 3 * cardSpaceWidth, Startup.haveFun);

    camera.viewfinder.visibleGameSize = gameSize;
    camera.viewfinder.position = Vector2(gameMidX, 0);
    camera.viewfinder.anchor = Anchor.topCenter;
    print('Sizes: finder ${camera.viewfinder.visibleGameSize} '
                   'port ${camera.viewport.size} screen $size');

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
            }
          );
        }
      }
    }
  }

  void deal(Startup startType) {
    switch(startType) {
      case Startup.first:
      case Startup.newDeal:
        print('Shuffle $startType ...');
        cards.shuffle();
        break;
      case Startup.changeDraw:
        _klondikeDraw = (_klondikeDraw == 3) ? 1 : 3;
        print('Draw $_klondikeDraw and shuffle...');
        cards.shuffle();
        break;
      case Startup.sameDeal:
      default:
        print('Replay same deal as before...');
        break;
    }

    print('Deal...');
    var cardToDeal = cards.length - 1;
    var nMovingCards = 0;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        Card card = cards[cardToDeal--];
        print('Card to move: $card, i $i, j $j, nMovingCards $nMovingCards');
        card.doMove(
          piles[j].position,
          start: nMovingCards * 0.15,
          onComplete: () {
            piles[j].acquireCard(card);
            nMovingCards--;
            print('Move done, i $i, j $j, $card $nMovingCards moving cards.');
            if (nMovingCards == 0) {
              var delayFactor = 0;
              for (TableauPile pile in piles) {
                delayFactor++;
                pile.flipTopCard(start: delayFactor * 0.15);
              }
              for (var m = 0; m < 7; m++) piles[m].printContents(m);
            }
          },
        );
        nMovingCards++;
      }
    }
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
    print('NCards ${cards.length}, cards $cards');
  }

  void addButton(String label, double buttonX, Startup action) {
    final button = FlatButton(
      label,
      size: Vector2(cardWidth, 0.6 * topGap),
      position: Vector2(buttonX, topGap / 2),
      onReleased: () {
        init(action);
      },
    );
    world.add(button);
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
