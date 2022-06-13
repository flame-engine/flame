import 'package:flame/components.dart';

import '../klondike_game.dart';
import 'card.dart';

class Stock extends PositionComponent {
  Stock({super.position})
    : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto the Stock pile.
  final List<Card> _cards = [];

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) {
      assert(card.isFaceDown);
      card.position = position;
    });
    _cards.addAll(cards);
  }
}
