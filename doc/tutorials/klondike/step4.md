# Gameplay

In this chapter we will be implementing the core of the Klondike's gameplay: how the cards move
between the stock and the waste, the piles and the foundations.

Before we begin though, let's clean up all those cards that we left scattered across the table in
the previous chapter. Open the `KlondikeGame` class and erase the loop at the bottom of `onLoad()`
that was adding 28 cards onto the table.


## Stock pile

The **stock** is a place in the top-left corner of the playing field which holds the cards that are
not currently in play. We will need to build the following functionality for this component:

1.  Ability to hold cards that are not currently in play (up to 24), face down;
2.  Tapping the stock should reveal top 3 cards and move them to the **waste** pile;
3.  When the cards run out, there should be a visual indicating that this is the stock pile;
4.  When the cards run out, tapping the empty stock should move all the cards from the waste pile
    into the stock, turning them face down.

The first question that needs to be decided here is this: who is going to own the `Card` components?
Previously we have been adding them directly to the game field, but now wouldn't it be better to
say that the cards belong to the `Stock` component, or to the waste, or piles, or foundations? While
this approach is tempting, I believe it would make our life more complicated as we need to move a
card from one place to another.

So, I decided to stick with my first approach: the `Card` components are owned directly by the
`KlondikeGame` itself, whereas the `Stock` and other piles are merely aware of which cards are
currently placed there.

Having this in mind, let's start implementing the `Stock` component:
```dart
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
```
Here the `acquireCards()` method stores the provided list of cards into an internal list `_cards`,
and also moves those cards on top of the `Stock`'s position. However, this method does not mount
the cards as children of the `Stock` component -- they remain belonging to the top-level game.

Speaking of the game class, let's open the `KlondikeGame` and add the following lines to create a
full deck of 52 cards and put them onto the stock pile (this should be added at the end of the
`onLoad` method):
```dart
final cards = [
  for (var rank = 2; rank <= 13; rank++)
    for (var suit = 0; suit < 4; suit++)
      Card(rank, suit)
];
world.addAll(cards);
stock.acquireCards(cards);
```

This concludes the first step of our short plan at the beginning of this section. For the second
step, though, we need to have a waste pile -- so let's make a quick detour and implement the `Waste`
class.


## Waste pile

The **waste** is a pile next to the stock. During the course of the game we will be taking the cards
from the top of the stock pile and putting them into the waste. The functionality of this class is
quite simple: it holds a certain number of cards face up, fanning out the top 3.

Let's start implementing the `Waste` class same way as we did with the `Stock` class, only now the
cards are expected to be face up.
```dart
class Waste extends PositionComponent {
  Waste({super.position})
    : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];

  void acquireCards(Iterable<Card> cards) {
    cards.forEach((card) {
      assert(card.isFaceUp);
      card.position = position;
    });
    _cards.addAll(cards);
  }
}
```
This works, but it puts all cards into a single neat pile, whereas we wanted a fan-out of top three.
So, let's add a dedicated method `_fanOutTopCards()` for this, which we will call after each
acquire:
```dart
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
```
The `_fanOffset` variable here helps determine the shift between cards in the fan, which I decided
to be about 30% of the card width:
```dart
  final Vector2 _fanOffset = Vector2(KlondikeGame.cardWidth * 0.3, 0);
```

Now that the waste pile is ready, let's get back to the `Stock`.


## Stock, continued

...


```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step4
:show: popup code
```
