import 'package:flame/components.dart';

import '../klondike_game.dart';
import 'card.dart';

class Foundation extends PositionComponent {
  Foundation({super.position}) : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];

  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }
}
