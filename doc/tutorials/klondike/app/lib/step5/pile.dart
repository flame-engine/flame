import 'components/card.dart';

enum MoveMethod { drag, tap }

abstract class Pile {
  /// Returns true if the [card] can be taken away from this pile and moved
  /// somewhere else. A tapping move may need additional validation.
  bool canMoveCard(Card card, MoveMethod method);

  /// Returns true if the [card] can be placed on top of this pile. The [card]
  /// may have other cards "attached" to it.
  bool canAcceptCard(Card card);

  /// Removes [card] from this pile; this method will only be called for a card
  /// that both belong to this pile, and for which [canMoveCard] returns true.
  void removeCard(Card card, MoveMethod method);

  /// Places a single [card] on top of this pile. This method will only be
  /// called for a card for which [canAcceptCard] returns true.
  void acquireCard(Card card);

  /// Returns a [card], which already belongs to this pile, to its proper place.
  void returnCard(Card card);
}
