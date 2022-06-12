import 'package:flame/components.dart';

import 'card.dart';

class Stock extends PositionComponent {
  Stock({super.size, super.position});

  /// Which cards are currently placed onto the Stock pile.
  final List<Card> _cards = [];

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) => card.position = position);
    _cards.addAll(cards);
  }
}
