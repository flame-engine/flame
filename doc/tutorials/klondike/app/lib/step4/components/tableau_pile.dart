import 'dart:ui';

import 'package:flame/components.dart';

import '../klondike_game.dart';
import '../pile.dart';
import 'card.dart';

class TableauPile extends PositionComponent implements Pile {
  TableauPile({super.position}) : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto this pile.
  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(0, KlondikeGame.cardHeight * 0.05);

  //#region Pile API

  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && card == _cards.last;

  @override
  bool canAcceptCard(Card card) {
    if (_cards.isEmpty) {
      return card.rank.value == 13;
    } else {
      final topCard = _cards.last;
      return card.suit.isRed == !topCard.suit.isRed &&
          card.rank.value == topCard.rank.value - 1;
    }
  }

  @override
  void removeCard(Card card) {
    assert(_cards.contains(card) && card.isFaceUp);
    final index = _cards.indexOf(card);
    _cards.removeRange(index, _cards.length);
    if (_cards.isNotEmpty && _cards.last.isFaceDown) {
      flipTopCard();
    }
  }

  @override
  void returnCard(Card card) {
    final index = _cards.indexOf(card);
    card.position =
        index == 0 ? position : _cards[index - 1].position + _fanOffset;
    card.priority = index;
  }

  @override
  void acquireCard(Card card) {
    if (_cards.isEmpty) {
      card.position = position;
    } else {
      card.position = _cards.last.position + _fanOffset;
    }
    card.pile = this;
    card.priority = _cards.length;
    _cards.add(card);
  }

  //#endregion

  void flipTopCard() {
    assert(_cards.last.isFaceDown);
    _cards.last.flip();
  }

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
  }

  //#endregion
}
