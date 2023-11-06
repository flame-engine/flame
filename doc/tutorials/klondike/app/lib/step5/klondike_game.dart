import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/card.dart';
import 'components/flat_button.dart';
import 'components/foundation_pile.dart';
import 'components/stock_pile.dart';
import 'components/tableau_pile.dart';
import 'components/waste_pile.dart';

enum Startup { first, newDeal, sameDeal, changeDraw, haveFun }

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

    for (var i = 0; i < 4; i++) {
      foundations.add(
        FoundationPile(
          i,
          checkWin,
          position: Vector2((i + 3) * cardSpaceWidth + cardGap, topGap),
        ),
      );
    }
    for (var i = 0; i < 7; i++) {
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

    final gameSize =
        Vector2(7 * cardSpaceWidth + cardGap, 4 * cardSpaceHeight + topGap);
    final gameMidX = gameSize.x / 2;

    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);
    world.addAll(cards);

    addButton('New deal', gameMidX, Startup.newDeal);
    addButton('Same deal', gameMidX + cardSpaceWidth, Startup.sameDeal);
    addButton('Draw 1 ⇌ 3', gameMidX + 2 * cardSpaceWidth, Startup.changeDraw);
    addButton('Have fun', gameMidX + 3 * cardSpaceWidth, Startup.haveFun);

    camera.viewfinder.visibleGameSize = gameSize;
    camera.viewfinder.position = Vector2(gameMidX, 0);
    camera.viewfinder.anchor = Anchor.topCenter;

    init(Startup.first);
  }

  void init(Startup startType) {
    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');
    if (startType == Startup.first) {
      deal(Startup.first);
    } else {
      stock.init();
      waste.init();
      foundations.forEach((foundation) => foundation.init());
      piles.forEach((tableau) => tableau.init());
      cards.forEach((card) => card.init());

      var nMovingCards = 0;
      for (final card in cards) {
        if (card.isFaceUp) {
          card.flip();
        }
        if ((card.position - stock.position).length > 1.0) {
          // Move cards that are not already in the Stock Pile.
          nMovingCards++;
          card.doMove(
            stock.position,
            onComplete: () {
              nMovingCards--;
              if (nMovingCards == 0) {
                deal(startType);
              }
            },
          );
        }
      }
    }
  }

  void deal(Startup startType) {
    switch (startType) {
      case Startup.first:
      case Startup.newDeal:
        cards.shuffle();
        break;
      case Startup.changeDraw:
        _klondikeDraw = (_klondikeDraw == 3) ? 1 : 3;
        cards.shuffle();
        break;
      case Startup.sameDeal:
      default:
        break;
    }

    var cardToDeal = cards.length - 1;
    var nMovingCards = 0;
    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        final card = cards[cardToDeal--];
        card.doMove(
          piles[j].position,
          start: nMovingCards * 0.15,
          onComplete: () {
            piles[j].acquireCard(card);
            nMovingCards--;
            if (nMovingCards == 0) {
              var delayFactor = 0;
              for (final pile in piles) {
                delayFactor++;
                pile.flipTopCard(start: delayFactor * 0.15);
              }
            }
          },
        );
        nMovingCards++;
      }
    }
    for (var n = 0; n <= cardToDeal; n++) {
      stock.acquireCard(cards[n]);
    }
  }

  void addButton(String label, double buttonX, Startup action) {
    final button = FlatButton(
      label,
      size: Vector2(cardWidth, 0.6 * topGap),
      position: Vector2(buttonX, topGap / 2),
      onReleased: () {
        if (action == Startup.haveFun) {
          letsCelebrate();
        } else {
          init(action);
        }
      },
    );
    world.add(button);
  }

  void checkWin() {
    var nComplete = 0;
    for (final f in foundations) {
      if (f.isFull) {
        nComplete++;
      }
    }
    if (nComplete == foundations.length) {
      letsCelebrate();
    }
  }

  void letsCelebrate({int phase = 1}) {
    // Deal won: bring all cards to the middle of the screen (phase 1)
    // then scatter them to points just outside the screen (phase 2).
    //
    // First get the device's screen-size in game co-ordinates, then get the
    // top-left of the off-screen area that will accept the scattered cards.
    // Note: The play area is anchored at TopCenter, so topLeft.y is fixed.

    final cameraZoom = camera.viewfinder.zoom;
    final zoomedScreen = size / cameraZoom;
    final playArea =
        Vector2(7 * cardSpaceWidth + cardGap, 4 * cardSpaceHeight + topGap);
    final screenCenter = (playArea - cardSize) / 2;
    final topLeft = Vector2(
      (playArea.x - zoomedScreen.x) / 2 - cardWidth,
      -cardHeight,
    );
    final nCards = cards.length;
    final h = zoomedScreen.y + cardSize.y; // Height of offscreen rect.
    final w = zoomedScreen.x + cardSize.x; // Width of offscreen rect.
    final ds = (h + w + h + w) / nCards; // Spacing = perimeter / nCards.

    // Starting points, directions and lengths of offscreen rect's sides.
    final corner = [
      Vector2(0.0, 0.0),
      Vector2(0.0, h),
      Vector2(w, h),
      Vector2(w, 0.0),
    ];
    final direction = [
      Vector2(0.0, 1.0),
      Vector2(1.0, 0.0),
      Vector2(0.0, -1.0),
      Vector2(-1.0, 0.0),
    ];
    final length = [
      h,
      w,
      h,
      w,
    ];

    var side = 0;
    var cardsToMove = nCards;
    var offScreenPosition = corner[side] + topLeft;
    var space = length[side];
    var cardNum = 0;

    while (cardNum < nCards) {
      final cardIndex = phase == 1 ? cardNum : nCards - cardNum - 1;
      final card = cards[cardIndex];
      card.priority = cardIndex + 1;
      if (card.isFaceDown) {
        card.flip();
      }
      // Start cards a short time apart to give a riffle effect.
      final delay = phase == 1 ? cardNum * 0.02 : 0.5 + cardNum * 0.04;
      final destination = (phase == 1) ? screenCenter : offScreenPosition;
      card.doMove(
        destination,
        speed: (phase == 1) ? 15.0 : 5.0,
        start: delay,
        onComplete: () {
          cardsToMove--;
          if (cardsToMove == 0) {
            if (phase == 1) {
              letsCelebrate(phase: 2);
            } else {
              init(Startup.newDeal);
            }
          }
        },
      );
      cardNum++;
      if (phase == 1) {
        continue;
      }

      // Phase 2: next card goes to same side with spacing ds, if possible.
      offScreenPosition = offScreenPosition + direction[side] * ds;
      space = space - ds;
      if ((space < 0.0) && (side < 3)) {
        // Out of space: change to the next side and use the excess ds there.
        side++;
        offScreenPosition = corner[side] + topLeft - direction[side] * space;
        space = length[side] + space;
      }
    }
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
