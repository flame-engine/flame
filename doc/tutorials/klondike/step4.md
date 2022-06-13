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
      card.priority = _cards.length;
      _cards.add(card);
    });
  }
}
```
Note that we are setting each card's `priority` here: this ensures that the cards will be rendered
in exactly the same order as they appear in the `_cards` list. We didn't do the same for the `Stock`
pile, because all cards there are face down, so it doesn't really matter in which order they are
rendered.

So far. this puts all cards into a single neat pile, whereas we wanted a fan-out of top three. So,
let's add a dedicated method `_fanOutTopCards()` for this, which we will call after each acquire:
```dart
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
```
The `_fanOffset` variable here helps determine the shift between cards in the fan, which I decided
to be about 30% of the card width:
```dart
  final Vector2 _fanOffset = Vector2(KlondikeGame.cardWidth * 0.2, 0);
```

Now that the waste pile is ready, let's get back to the `Stock`.


## Stock, continued

### Tap to deal cards

The second item on our todo list is the first interactive functionality in the game: tap the stock
pile to deal 3 cards onto the waste.

Adding tap functionality to the components in Flame is quite simple: first, we add the mixin
`HasTappableComponents` to our top-level game class:
```dart
class KlondikeGame extends FlameGame with HasTappableComponents { ... }
```
And second, we add the mixin `TapCallbacks` to the component that we want to be tappable:
```dart
class Stock extends PositionComponent with TapCallbacks { ... }
```
Oh, and we also need to say what we want to happen when the tap occurs. Here we want the top 3 cards
to be turned faced up and moved to the waste pile. So, add the following method to the `Stock`
class:
```dart
  /// Reference to the waste pile component
  late final Waste _waste = parent!.firstChild<Waste>()!;

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
```
We are careful to remove the cards from the top of the pile one-by-one, so that their proper order
is ensured when adding them to the waste pile.

You will also notice that the cards move from one pile to another immediately, which looks very
unnatural. However, this is how it is going to be for now -- we will defer making the game more
smooth till the next chapter of the tutorial.

```{seealso}
For more information about tap functionality, see [](../../flame/inputs/tap-events.md).
```


### Empty stock pile

Currently, when the stock pile has no cards, it simply shows an empty space -- there is no visual
cue that this is where the stock is. Such cue is needed, though, because we want the user to be
able to click the stock pile when it is empty in order to move all the cards from the waste back to
the stock so that they can be dealt again.

In our case, the empty stock pile will have a card-like border, and a circle in the middle:
```dart
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      KlondikeGame.cardWidth * 0.3,
      _circlePaint,
    );
  }
```
where the paints are defined as
```dart
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);
  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);
```
and the `cardRRect` in the `KlondikeGame` class as
```dart
  static const cardRRect = RRect.fromLTRBXY(
    0,
    0,
    cardWidth,
    cardHeight,
    cardRadius,
    cardRadius,
  );
```

Now when you click through the stock pile till the end, you should be able to see the placeholder
for the stock cards.


### Return cards from the waste pile

The last piece of functionality to add, is to move the cards back from the waste pile into the stock
pile when the user taps on an empty stock. To implement this, we will modify the `onTapUp()` method
like so:
```dart
  void onTapUp(TapUpEvent event) {
    if (_cards.isEmpty) {
      acquireCards(_waste.removeAllAndFlip());
    } else {
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
```
Where the function `Waste.removeAllAndFlip()` still needs to be implemented. This method's job will
be to remove all cards that are currently in the waste pile, flip them upside-down, and hand them
over to the stock pile.
```dart
  List<Card> removeAllAndFlip() {
    final cards = _cards.reversed.toList();
    _cards.clear();
    cards.forEach((card) => card.flip());
    return cards;
  }
```
If you're curious why we had to have `_cards.reversed` here, then it is because we want to simulate
the entire waste pile being turned over at once, and not each card being flipped one by one in their
places. You can check that this is working as intended by verifying that on each subsequent run
through the stock pile, the cards are dealt in the same order as they were dealt in the first run.

This pretty much concludes the `Stock` functionality, and we already implemented the `Waste` -- so
the only two components remaining are the `Foundation` and the `Pile`. We'll start with the
`Foundation` because it looks simpler.


## Foundation piles

The **foundation** piles are the four piles in the top right corner of the game. This is where we
will be building the ordered runs of cards from Ace to King. The functionality of this class is
similar to the `Stock` and the `Waste`: it has to be able to hold cards face up, and there has to
be some visual to show where the foundation is when there are no cards there.

First, let's implement the card-holding logic:
```dart
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
```
The `acquireCard()` method here only takes a single card instead of an iterable, because there's
really never a situation where we would need to add multiple cards at once to the foundation.

For visual representation of a foundation, I've decided to make a large icon of that foundation's
suit, in grey color. Which means we'd need to update the definition of the `Foundation` class:
```dart
class Foundation extends PositionComponent {
  Foundation(int intSuit, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final Suit suit;
  ...
}
```
The code in the `KlondikeGame` class that generates the foundations will have to be adjusted
accordingly in order to pass the suit index to each foundation.

Now, the rendering code will look like this:
```dart
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    suit.sprite.render(
      canvas,
      position: size / 2,
      anchor: Anchor.center,
      size: Vector2.all(KlondikeGame.cardWidth * 0.6),
      overridePaint: _suitPaint,
    );
  }
```
Here we need two paint objects, one for the border and one for the suits:
```dart
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed? const Color(0x36000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;
```
The suit paint uses `BlendMode.luminosity` in order to convert the regular yellow/blue colors of
the suit sprites into greyscale. The "color" of the paint is different depending whether the suit
is red or black because the original luminosity of those sprites is different. Therefore, I had to
pick two different colors in order to make them look the same in greyscale.


## Tableau Piles

The last piece of the game to be implemented is the `Pile` component. There are seven piles in
total, and they are where the majority of the game play is happening.

The `Pile` also needs a visual representation, in order to indicate that it's a place where a King
can be placed when it is empty. I believe it could be just an empty frame, and that should be
sufficient:
```dart
class Pile extends PositionComponent {
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
  }
}
```

Oh, and the class will need to be able hold the cards too, obviously. Here, some of the cards will
be face down, while others will be face up. We will need a small amount of vertical fanning too,
similar to how we did it for the `Waste` component:
```dart
  /// Which cards are currently placed onto this Pile.
  final List<Card> _cards = [];
  final Vector2 _fanOffset = Vector2(0, KlondikeGame.cardHeight * 0.05);

  void acquireCard(Card card) {
    if (_cards.isEmpty) {
      card.position = position;
    } else {
      card.position = _cards.last.position + _fanOffset;
    }
    card.priority = _cards.length;
    _cards.add(card);
  }
```

All that remains now is to head over to the `KlondikeGame` and make sure that the cards are dealt
into the `Pile`s at the beginning of the game. Add the following code at the end of the `onLoad()`
method:
```dart
  Future<void> onLoad() async {
    ...

    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards.removeLast());
      }
    }
    piles.forEach((pile) => pile.flipTopCard());
    stock.acquireCards(cards);
  }
```
Note how we remove the cards from the deck and place them into `Pile`s one by one, and only after
that put the remaining cards into the `stock`. Also, the `flipTopCard` method in the `Pile` class
is as trivial as it sounds:
```dart
  void flipTopCard() {
    assert(_cards.last.isFaceDown);
    _cards.last.flip();
  }
```

This is it! Let's run the game, and... ok we forgot to shuffle. Add the line `cards.shuffle()` in
the `KlondikeGame` constructor when we're creating the list of cards.

Ok, this is it, everything's ready! Let's run the game... The cards don't move. That seems like a
big oversight on my part, so without further ado, presenting you the next section:


## Moving the cards

<!-- So, we want to be able to drag the cards on the screen. This isn't as difficult as it sounds -->


<!-- ```{flutter-app} -->
<!-- :sources: ../tutorials/klondike/app -->
<!-- :page: step4 -->
<!-- :show: popup code -->
<!-- ``` -->
