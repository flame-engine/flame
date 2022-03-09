import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/experimental.dart';

import 'components/foundation.dart';
import 'components/pile.dart';
import 'components/stock.dart';
import 'components/waste.dart';

class KlondikeGame extends FlameGame {
  bool _initialized = false; // FIXME (#1351)
  late final Stock stock;
  late final Waste waste;
  late final List<Foundation> foundations;
  late final List<Pile> piles;

  @override
  Future<void> onLoad() async {
    await images.load('klondike-sprites.png');
    final world = World();
    stock = Stock()
      ..size = Vector2(1000, 1400)
      ..position = Vector2(0, 0)
      ..addToParent(this);
    waste = Waste();
    foundations = [Foundation(), Foundation(), Foundation(), Foundation()];
    piles = [for (var i = 0; i < 7; i++) Pile()];

    // add(stock);
    add(waste);
    addAll(foundations);
    addAll(piles);
    _initialized = true;
    _performLayout();
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    if (_initialized) {
      _performLayout();
    }
  }

  void _performLayout() {
    final canvasWidth = canvasSize.x;
    final canvasHeight = canvasSize.y;
    final cardWidth = min(canvasWidth / 8, canvasHeight / 5);
    final cardHeight = 1.4 * cardWidth;
    final gap = cardWidth / 8;
    final horizontalPadding = (canvasWidth - 7 * cardWidth - 6 * gap) / 2;

    waste
      ..size.setValues(cardWidth * 1.5, cardHeight)
      ..position.setValues(horizontalPadding + cardWidth + gap, gap);
    for (var i = 0; i < 4; i++) {
      foundations[i]
        ..size.setValues(cardWidth, cardHeight)
        ..position.setValues(
          canvasWidth - horizontalPadding - i * (cardWidth + gap) - cardWidth,
          gap,
        );
    }
    for (var i = 0; i < 7; i++) {
      piles[i]
        ..size.setValues(cardWidth, cardHeight)
        ..position.setValues(
          horizontalPadding + i * (cardWidth + gap),
          cardHeight + 2 * gap,
        );
    }
  }
}
