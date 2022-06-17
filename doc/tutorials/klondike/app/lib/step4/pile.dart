import 'components/card.dart';

abstract class Pile {
  bool canMoveCard(Card card);

  bool canAcceptCard(Card card);

  void removeCard(Card card);

  void acquireCard(Card card);

  void returnCard(Card card);
}
