import 'package:flame/components.dart';

import '../klondike_game.dart';
import 'card.dart';

class Waste extends PositionComponent {
  Waste({super.position}) : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(KlondikeGame.cardWidth * 0.3, 0);

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) {
      assert(card.isFaceUp);
      card.position = position;
    });
    _cards.addAll(cards);
    _fanOutTopCards();
  }

  void _fanOutTopCards() {
    final n = _cards.length;
    if (n == 1) {
      _cards[0].position = position;
    } else if (n == 2) {
      _cards[0].position = position;
      _cards[1].position = position + _fanOffset;
    } else if (n >= 3) {
      _cards[n - 1].position = position + _fanOffset * 2;
      _cards[n - 2].position = position + _fanOffset;
      for (var i = 0; i < n - 2; i++) {
        _cards[i].position = position;
      }
    }
  }
}
