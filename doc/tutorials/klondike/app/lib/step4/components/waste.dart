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
      card.priority = _cards.length;
      _cards.add(card);
    });
    _fanOutTopCards();
  }

  void _fanOutTopCards() {
    final n = _cards.length;
    for (var i = 0; i < n; i++) {
      _cards[i].position = position;
    }
    if (n == 2) {
      _cards[1].position.add(_fanOffset);
    } else if (n >= 3) {
      _cards[n - 2].position.add(_fanOffset);
      _cards[n - 1].position.addScaled(_fanOffset, 2);
    }
  }
}
