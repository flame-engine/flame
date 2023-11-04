import 'package:flame/components.dart';

import 'components/card.dart';

abstract class Pile {

  /// Clear all cards from this pile when re-initializing KlondikeGame.
  void init();

  /// Show where to drop the card(s) after a successful drag-and-drop move.
  Vector2 dropPosition();

  /// Returns true if the [card] can be taken away from this pile and moved
  /// somewhere else.
  bool canMoveCard(Card card);

  /// Returns true if the [card] can be placed on top of this pile. The [card]
  /// may have other cards "attached" to it.
  bool canAcceptCard(Card card);

  /// Removes [card] from this pile; this method will only be called for a card
  /// that both belong to this pile, and for which [canMoveCard] returns true.
  void removeCard(Card card);

  /// Places a single [card] on top of this pile. This method will only be
  /// called for a card for which [canAcceptCard] returns true.
  void acquireCard(Card card);

  /// Returns the [card] (which already belongs to this pile) in its proper
  /// place.
  void returnCard(Card card);
}
