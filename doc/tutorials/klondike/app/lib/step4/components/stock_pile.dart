import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import '../klondike_game.dart';
import 'card.dart';
import 'waste_pile.dart';

class StockPile extends PositionComponent with TapCallbacks {
  StockPile({super.position}) : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto the Stock pile.
  final List<Card> _cards = [];

  /// Reference to the waste pile component
  late final WastePile _waste = parent!.firstChild<WastePile>()!;

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) {
      assert(card.isFaceDown);
      card.position = position;
    });
    _cards.addAll(cards);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_cards.isEmpty) {
      acquireCards(_waste.removeAllAndFlip());
    } else {
      final removedCards = <Card>[];
      for (var i = 0; i < 3; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          removedCards.add(card);
        }
      }
      _waste.acquireCards(removedCards);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      KlondikeGame.cardWidth * 0.3,
      _circlePaint,
    );
  }
}
