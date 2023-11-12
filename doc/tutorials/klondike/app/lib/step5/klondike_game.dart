import 'dart:ui';
import 'dart:math';

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

  // Used when creating Random seed. Cannot use the full 2^63 in Web apps.
  static const int maxint = 2 ^ 53 - 1;

  // Default is Klondike Draw 1: a button switches between Draw 1 and Draw 3.
  var _klondikeDraw = 1;

  int get klondikeDraw => _klondikeDraw;

  final klondikeWorld = KlondikeWorld(klondikeDraw: 1);

  @override
  Future<void> onLoad() async {
    add(klondikeWorld);
  }

  void init(Startup startType) {
    if (startType == Startup.first) {
      deal(Startup.first);
    } else {}
  }

  void deal(Startup startType) {
    print('Deal: start type $startType');
    final cards = klondikeWorld.cards;
    final tableauPiles = klondikeWorld.tableauPiles;
    final stock = klondikeWorld.stock;

    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');
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
          tableauPiles[j].position,
          start: nMovingCards * 0.15,
          onComplete: () {
            tableauPiles[j].acquireCard(card);
            nMovingCards--;
            if (nMovingCards == 0) {
              var delayFactor = 0;
              for (final tableauPile in tableauPiles) {
                delayFactor++;
                tableauPile.flipTopCard(start: delayFactor * 0.15);
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

  void checkWin() {
    final foundations = klondikeWorld.foundations;

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

    final cards = klondikeWorld.cards;

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
    final offscreenHeight = zoomedScreen.y + cardSize.y;
    final offscreenWidth = zoomedScreen.x + cardSize.x;
    final spacing = 2.0 * (offscreenHeight + offscreenWidth) / nCards;

    // Starting points, directions and lengths of offscreen rect's sides.
    final corner = [
      Vector2(0.0, 0.0),
      Vector2(0.0, offscreenHeight),
      Vector2(offscreenWidth, offscreenHeight),
      Vector2(offscreenWidth, 0.0),
    ];
    final direction = [
      Vector2(0.0, 1.0),
      Vector2(1.0, 0.0),
      Vector2(0.0, -1.0),
      Vector2(-1.0, 0.0),
    ];
    final length = [
      offscreenHeight,
      offscreenWidth,
      offscreenHeight,
      offscreenWidth,
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

      // Phase 2: next card goes to same side with full spacing, if possible.
      offScreenPosition = offScreenPosition + direction[side] * spacing;
      space = space - spacing;
      if ((space < 0.0) && (side < 3)) {
        // Out of space: change to the next side and use excess spacing there.
        side++;
        offScreenPosition = corner[side] + topLeft - direction[side] * space;
        space = length[side] + space;
      }
    }
  }
}

class KlondikeWorld extends World with HasGameReference<KlondikeGame> {
  KlondikeWorld({this.klondikeDraw = 1, this.seed});

  final cardGap = KlondikeGame.cardGap;
  final topGap = KlondikeGame.topGap;
  final cardSpaceWidth = KlondikeGame.cardSpaceWidth;
  final cardSpaceHeight = KlondikeGame.cardSpaceHeight;

  // Default is Klondike Draw 1: a button switches between Draw 1 and Draw 3.
  final int klondikeDraw;

  // The seed is used to make the shuffle repeat when "Same deal" is requested.
  int? seed;
  late Random random;

  final stock = StockPile(position: Vector2(0.0, 0.0));
  final waste = WastePile(position: Vector2(0.0, 0.0));
  final List<FoundationPile> foundations = [];
  final List<TableauPile> tableauPiles = [];
  final List<Card> cards = [];

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    stock.position = Vector2(cardGap, topGap);
    waste.position = Vector2(cardSpaceWidth + cardGap, topGap);

    for (var i = 0; i < 4; i++) {
      foundations.add(
        FoundationPile(
          i,
          game.checkWin,
          position: Vector2((i + 3) * cardSpaceWidth + cardGap, topGap),
        ),
      );
    }
    for (var i = 0; i < 7; i++) {
      tableauPiles.add(
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
        cards.add(Card(this, rank, suit));
      }
    }

    final gameSize =
        Vector2(7 * cardSpaceWidth + cardGap, 4 * cardSpaceHeight + topGap);
    final gameMidX = gameSize.x / 2;

    add(stock);
    add(waste);
    addAll(foundations);
    addAll(tableauPiles);
    addAll(cards);

    addButton('New deal', gameMidX, Startup.newDeal);
    addButton('Same deal', gameMidX + cardSpaceWidth, Startup.sameDeal);
    addButton('Draw 1 or 3', gameMidX + 2 * cardSpaceWidth, Startup.changeDraw);
    addButton('Have fun', gameMidX + 3 * cardSpaceWidth, Startup.haveFun);

    game.camera.world = this;
    game.camera.viewfinder.visibleGameSize = gameSize;
    game.camera.viewfinder.position = Vector2(gameMidX, 0);
    game.camera.viewfinder.anchor = Anchor.topCenter;

    // This creates a random seed if one was not supplied.
    seed ??= Random().nextInt(KlondikeGame.maxint);
    // This creates the random generator that should be used everywhere for shuffling etc.
    random = Random(seed);
    // ...
    // This would maybe not be done in this method, just showing how to pass the random class to it.
    cards.shuffle(random);
    game.init(Startup.first);
  }

  void addButton(String label, double buttonX, Startup action) {
    final button = FlatButton(
      label,
      size: Vector2(KlondikeGame.cardWidth, 0.6 * topGap),
      position: Vector2(buttonX, topGap / 2),
      onReleased: () {
        if (action == Startup.haveFun) {
          game.letsCelebrate();
        } else {
          game.init(action);
        }
      },
    );
    add(button);
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
