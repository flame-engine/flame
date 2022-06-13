import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import '../klondike_game.dart';
import 'card.dart';
import 'waste.dart';

class Stock extends PositionComponent with TapCallbacks {
  Stock({super.position})
    : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto the Stock pile.
  final List<Card> _cards = [];

  /// Reference to the waste pile component
  late final Waste _waste = parent!.firstChild<Waste>()!;

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) {
      assert(card.isFaceDown);
      card.position = position;
    });
    _cards.addAll(cards);
  }

  @override
  void onTapUp(TapUpEvent event) {
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
