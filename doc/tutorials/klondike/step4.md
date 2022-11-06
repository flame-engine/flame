# Gameplay

In this chapter we will be implementing the core of Klondike's gameplay: how the cards move between
the stock and the waste, the piles and the foundations.

Before we begin though, let's clean up all those cards that we left scattered across the table in
the previous chapter. Open the `KlondikeGame` class and erase the loop at the bottom of `onLoad()`
that was adding 28 cards onto the table.


## The piles

Another small refactoring that we need to do is to rename our components: `Stock` ⇒ `StockPile`,
`Waste` ⇒ `WastePile`, `Foundation` ⇒ `FoundationPile`, and `Pile` ⇒ `TableauPile`. This is
because these components have some common features in how they handle interactions with the cards,
and it would be convenient to have all of them implement a common API. We will call the interface
that they will all be implementing the `Pile` class.

```{note}
Refactors and changes in architecture happen during development all the time:
it's almost impossible to get the structure right on the first try. Do not be
anxious about changing code that you have written in the past: it is a good
habit to have.
```

After such a rename, we can begin implementing each of these components.


### Stock pile

The **stock** is a place in the top-left corner of the playing field which holds the cards that are
not currently in play. We will need to build the following functionality for this component:

1. Ability to hold cards that are not currently in play, face down;
2. Tapping the stock should reveal top 3 cards and move them to the **waste** pile;
3. When the cards run out, there should be a visual indicating that this is the stock pile;
4. When the cards run out, tapping the empty stock should move all the cards from the waste pile
    into the stock, turning them face down.

The first question that needs to be decided here is this: who is going to own the `Card` components?
Previously we have been adding them directly to the game field, but now wouldn't it be better to
say that the cards belong to the `Stock` component, or to the waste, or piles, or foundations? While
this approach is tempting, I believe it would make our life more complicated as we need to move a
card from one place to another.

So, I decided to stick with my first approach: the `Card` components are owned directly by the
`KlondikeGame` itself, whereas the `StockPile` and other piles are merely aware of which cards are
currently placed there.

Having this in mind, let's start implementing the `StockPile` component:

```dart
class StockPile extends PositionComponent {
  StockPile({super.position}) : super(size: KlondikeGame.cardSize);

  /// Which cards are currently placed onto this pile. The first card in the
  /// list is at the bottom, the last card is on top.
  final List<Card> _cards = [];

  void acquireCard(Card card) {
    assert(!card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }
}
```

Here the `acquireCard()` method stores the provided card into the internal list `_cards`; it also
moves that card to the `StockPile`'s position and adjusts the cards priority so that they are
displayed in the right order. However, this method does not mount the card as a child of the
`StockPile` component -- it remains belonging to the top-level game.

Speaking of the game class, let's open the `KlondikeGame` and add the following lines to create a
full deck of 52 cards and put them onto the stock pile (this should be added at the end of the
`onLoad` method):

```dart
final cards = [
  for (var rank = 1; rank <= 13; rank++)
    for (var suit = 0; suit < 4; suit++)
      Card(rank, suit)
];
world.addAll(cards);
cards.forEach(stock.acquireCard);
```

This concludes the first step of our short plan at the beginning of this section. For the second
step, though, we need to have a waste pile -- so let's make a quick detour and implement the
`WastePile` class.


### Waste pile

The **waste** is a pile next to the stock. During the course of the game we will be taking the cards
from the top of the stock pile and putting them into the waste. The functionality of this class is
quite simple: it holds a certain number of cards face up, fanning out the top 3.

Let's start implementing the `WastePile` class same way as we did with the `StockPile` class, only
now the cards are expected to be face up:

```dart
class WastePile extends PositionComponent {
  WastePile({super.position}) : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];

  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }
}
```

So far, this puts all cards into a single neat pile, whereas we wanted a fan-out of top three. So,
let's add a dedicated method `_fanOutTopCards()` for this, which we will call at the end of each
`acquireCard()`:

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
to be about 20% of the card's width:

```dart
  final Vector2 _fanOffset = Vector2(KlondikeGame.cardWidth * 0.2, 0);
```

Now that the waste pile is ready, let's get back to the `StockPile`.


### Stock pile -- tap to deal cards

The second item on our todo list is the first interactive functionality in the game: tap the stock
pile to deal 3 cards onto the waste.

Adding tap functionality to the components in Flame is quite simple: first, we add the mixin
`HasTappableComponents` to our top-level game class:

```dart
class KlondikeGame extends FlameGame with HasTappableComponents { ... }
```

And second, we add the mixin `TapCallbacks` to the component that we want to be tappable:

```dart
class StockPile extends PositionComponent with TapCallbacks { ... }
```

Oh, and we also need to say what we want to happen when the tap occurs. Here we want the top 3 cards
to be turned face up and moved to the waste pile. So, add the following method to the `StockPile`
class:

```dart
  @override
  void onTapUp(TapUpEvent event) {
  final wastePile = parent!.firstChild<WastePile>()!;
    for (var i = 0; i < 3; i++) {
      if (_cards.isNotEmpty) {
        final card = _cards.removeLast();
        card.flip();
        wastePile.acquireCard(card);
      }
    }
  }
```

You have probably noticed that the cards move from one pile to another immediately, which looks very
unnatural. However, this is how it is going to be for now -- we will defer making the game more
smooth till the next chapter of the tutorial.

Also, the cards are organized in a well-defined order right now, starting from Kings and ending with
Aces. This doesn't make a very exciting gameplay though, so add line

```dart
    cards.shuffle();
```

in the `KlondikeGame` class right after the list of cards is created.


```{seealso}
For more information about tap functionality, see [](../../flame/inputs/tap-events.md).
```


### Stock pile -- visual representation

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
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );
```

Now when you click through the stock pile till the end, you should be able to see the placeholder
for the stock cards.


### Stock pile -- refill from the waste

The last piece of functionality to add, is to move the cards back from the waste pile into the stock
pile when the user taps on an empty stock. To implement this, we will modify the `onTapUp()` method
like so:

```dart
  @override
  void onTapUp(TapUpEvent event) {
    final wastePile = parent!.firstChild<WastePile>()!;
    if (_cards.isEmpty) {
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < 3; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          wastePile.acquireCard(card);
        }
      }
    }
  }
```

If you're curious why we needed to reverse the list of cards removed from the waste pile, then it is
because we want to simulate the entire waste pile being turned over at once, and not each card being
flipped one by one in their places. You can check that this is working as intended by verifying that
on each subsequent run through the stock pile, the cards are dealt in the same order as they were
dealt in the first run.

The method `WastePile.removeAllCards()` still needs to be implemented though:

```dart
  List<Card> removeAllCards() {
    final cards = _cards.toList();
    _cards.clear();
    return cards;
  }
```

This pretty much concludes the `StockPile` functionality, and we already implemented the `WastePile`
-- so the only two components remaining are the `FoundationPile` and the `TableauPile`. We'll start
with the first one because it looks simpler.


### Foundation piles

The **foundation** piles are the four piles in the top right corner of the game. This is where we
will be building the ordered runs of cards from Ace to King. The functionality of this class is
similar to the `StockPile` and the `WastePile`: it has to be able to hold cards face up, and there
has to be some visual to show where the foundation is when there are no cards there.

First, let's implement the card-holding logic:

```dart
class FoundationPile extends PositionComponent {
  FoundationPile({super.position}) : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];

  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }
}
```

For visual representation of a foundation, I've decided to make a large icon of that foundation's
suit, in grey color. Which means we'd need to update the definition of the class to include the
suit information:

```dart
class FoundationPile extends PositionComponent {
  FoundationPile(int intSuit, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final Suit suit;
  ...
}
```

The code in the `KlondikeGame` class that generates the foundations will have to be adjusted
accordingly in order to pass the suit index to each foundation.

Now, the rendering code for the foundation pile will look like this:

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

Here we need to have two paint objects, one for the border and one for the suits:

```dart
  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed? const Color(0x3a000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;
```

The suit paint uses `BlendMode.luminosity` in order to convert the regular yellow/blue colors of
the suit sprites into grayscale. The "color" of the paint is different depending whether the suit
is red or black because the original luminosity of those sprites is different. Therefore, I had to
pick two different colors in order to make them look the same in grayscale.


### Tableau Piles

The last piece of the game to be implemented is the `TableauPile` component. There are seven of
these piles in total, and they are where the majority of the game play is happening.

The `TableauPile` also needs a visual representation, in order to indicate that it's a place where
a King can be placed when it is empty. I believe it could be just an empty frame, and that should
be sufficient:

```dart
class TableauPile extends PositionComponent {
  TableauPile({super.position}) : super(size: KlondikeGame.cardSize);

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
be face down, while others will be face up. Also we will need a small amount of vertical fanning,
similar to how we did it for the `WastePile` component:

```dart
  /// Which cards are currently placed onto this pile.
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
into the `TableauPile`s at the beginning of the game. Modify the code at the end of the `onLoad()`
method so that it looks like this:

```dart
  Future<void> onLoad() async {
    ...

    final cards = [
      for (var rank = 1; rank <= 13; rank++)
        for (var suit = 0; suit < 4; suit++)
          Card(rank, suit)
    ];
    cards.shuffle();
    world.addAll(cards);

    for (var i = 0; i < 7; i++) {
      for (var j = i; j < 7; j++) {
        piles[j].acquireCard(cards.removeLast());
      }
      piles[i].flipTopCard();
    }
    cards.forEach(stock.acquireCard);
  }
```

Note how we remove the cards from the deck and place them into `TableauPile`s one by one, and only
after that we put the remaining cards into the stock. Also, the `flipTopCard` method in the
`TableauPile` class is as trivial as it sounds:

```dart
  void flipTopCard() {
    assert(_cards.last.isFaceDown);
    _cards.last.flip();
  }
```

If you run the game at this point, it would be nicely set up and look as if it was ready to play.
Except that we can't move the cards yet, which is kinda a deal-breaker here. So without further ado,
presenting you the next section:


## Moving the cards

Moving the cards is a somewhat more complicated topic than what we have had so far. We will split
it into several smaller steps:

1. Simple movement: grab a card and move it around.
2. Ensure that the user can only move the cards that they are allowed to.
3. Check that the cards are dropped at proper destinations.
4. Drag a run of cards.


### 1. Simple movement

So, we want to be able to drag the cards on the screen. This is almost as simple as making the
`StockPile` tappable: first, we add the `HasDraggableComponents` mixin to our game class:

```dart
class KlondikeGame extends FlameGame
    with HasTappableComponents, HasDraggableComponents {
  ...
}
```

Now, head over into the `Card` class and add the `DragCallbacks` mixin:

```dart
class Card extends PositionComponent with DragCallbacks {
}
```

The next step is to implement the actual drag event callbacks: `onDragStart`, `onDragUpdate`, and
`onDragEnd`.

When the drag gesture is initiated, the first thing that we need to do is to raise the priority of
the card, so that it is rendered above all others. Without this, the card would be occasionally
"sliding beneath" other cards, which would look most unnatural:

```dart
  @override
  void onDragStart(DragStartEvent event) {
    priority = 100;
  }
```

During the drag, the `onDragUpdate` event will be called continuously. Using this callback we will
be updating the position of the card so that it follows the movement of the finger (or the mouse).
The `event` object passed to this callback contains the most recent coordinate of the point of
touch, and also the `delta` property -- which is the displacement vector since the previous call of
`onDragUpdate`. The only problem is that this delta is measured in screen pixels, whereas we want
it to be in game world units. The conversion between the two is given by the camera zoom level, so
we will add an extra method to determine the zoom level:

```dart
  @override
  void onDragUpdate(DragUpdateEvent event) {
    final cameraZoom = (findGame()! as FlameGame)
        .firstChild<CameraComponent>()!
        .viewfinder
        .zoom;
    position += event.delta / cameraZoom;
  }
```

So far this allows you to grab any card and drag it anywhere around the table. What we want,
however, is to be able to restrict where the card is allowed or not allowed to go. This is where
the core of the logic of the game begins.


### 2. Move only allowed cards

The first restriction that we impose is that the user should only be able to drag the cards that we
allow, which include: (1) the top card of a waste pile, (2) the top card of a foundation pile, and
(3) any face-up card in a tableau pile.

Thus, in order to determine whether a card can be moved or not, we need to know which pile it
currently belongs to. There could be several ways that we go about it, but seemingly the most
straightforward is to let every card keep a reference to the pile in which it currently resides.

So, let's start by defining the abstract interface `Pile` that all our existing piles will be
implementing:

```dart
abstract class Pile {
  bool canMoveCard(Card card);
}
```

We will expand this class further later, but for now let's make sure that each of the classes
`StockPile`, `WastePile`, `FoundationPile`, and `TableauPile` are marked as implementing this
interface:

```dart
class StockPile extends PositionComponent with TapCallbacks implements Pile {
  ...
  @override
  bool canMoveCard(Card card) => false;
}

class WastePile extends PositionComponent implements Pile {
  ...
  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && card == _cards.last;
}

class FoundationPile extends PositionComponent implements Pile {
  ...
  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && card == _cards.last;
}

class TableauPile extends PositionComponent implements Pile {
  ...
  @override
  bool canMoveCard(Card card) => _cards.isNotEmpty && card == _cards.last;
}
```

We also wanted to let every `Card` know which pile it is currently in. For this, add the field
`Pile? pile` into the `Card` class, and make sure to set it in each pile's `acquireCard()` method,
like so:

```dart
  void acquireCard(Card card) {
    ...
    card.pile = this;
  }
```

Now we can put this new functionality to use: go into the `Card.onDragStart()` method and modify
it so that it would check whether the card is allowed to be moved before starting the drag:

```dart
  void onDragStart(DragStartEvent event) {
    if (pile?.canMoveCard(this) ?? false) {
      _isDragging = true;
      priority = 100;
    }
  }
```

We have also added the boolean `_isDragging` variable here: make sure to define it, and then to
check this flag in the `onDragUpdate()` method, and to set it back to false in the `onDragEnd()`:

```dart
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final cameraZoom = (findGame()! as FlameGame)
        .firstChild<CameraComponent>()!
        .viewfinder
        .zoom;
    position += event.delta / cameraZoom;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
  }
```

Now the only the proper cards can be dragged, but they still drop at random positions on the table,
so let's work on that.


### 3. Dropping the cards at proper locations

At this point what we want to do is to figure out where the dragged card is being dropped. More
specifically, we want to know into which *pile* it is being dropped. This can be achieved by using
the `componentsAtPoint()` API, which allows you to query which components are located at a given
position on the screen.

Thus, my first attempt at revising the `onDragEnd` callback looks like this:

```dart
  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      // if (card is allowed to be dropped into this pile) {
      //   remove the card from the current pile
      //   add the card into the new pile
      // }
    }
    // return the card to where it was originally
  }
```

This still contains several placeholders for the functionality that still needs to be implemented,
so let's get to it.

First piece of the puzzle is the "is card allowed to be dropped here?" check. To implement this,
first head over into the `Pile` class and add the `canAcceptCard()` abstract method:

```dart
abstract class Pile {
  ...
  bool canAcceptCard(Card card);
}
```

Obviously this now needs to be implemented for every `Pile` subclass, so let's get to it:

```dart
class FoundationPile ... implements Pile {
  ...
  @override
  bool canAcceptCard(Card card) {
    final topCardRank = _cards.isEmpty? 0 : _cards.last.rank.value;
    return card.suit == suit && card.rank.value == topCardRank + 1;
  }
}

class TableauPile ... implements Pile {
  ...
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
}
```

(for the `StockPile` and the `WastePile` the method should just return false, since no cards should
be dropped there).

Alright, next part is the "remove the card from its current pile". Once again, let's head over to
the `Pile` class and add the `removeCard()` abstract method:

```dart
abstract class Pile {
  ...
  void removeCard(Card card);
}
```

Then we need to re-visit all four pile subclasses and implement this method:

```dart
class StockPile ... implements Pile {
  ...
  @override
  void removeCard(Card card) => throw StateError('cannot remove cards from here');
}

class WastePile ... implements Pile {
  ...
  @override
  void removeCard(Card card) {
    assert(canMoveCard(card));
    _cards.removeLast();
    _fanOutTopCards();
  }
}

class FoundationPile ... implements Pile {
  ...
  @override
  void removeCard(Card card) {
    assert(canMoveCard(card));
    _cards.removeLast();
  }
}

class TableauPile ... implements Pile {
  ...
  @override
  void removeCard(Card card) {
    assert(_cards.contains(card) && card.isFaceUp);
    final index = _cards.indexOf(card);
    _cards.removeRange(index, _cards.length);
    if (_cards.isNotEmpty && _cards.last.isFaceDown) {
      flipTopCard();
    }
  }
}
```

The next action in our pseudo-code is to "add the card to the new pile". But this one we have
already implemented: it's the `acquireCard()` method. So all we need is to declare it in the `Pile`
interface:

```dart
abstract class Pile {
  ...
  void acquireCard(Card card);
}
```

The last piece that's missing is "return the card to where it was". You can probably guess how we
are going to go about this one: add the `returnCard()` method into the `Pile` interface, and then
implement this method in all four pile subclasses:

```dart
class StockPile ... implements Pile {
  ...
  @override
  void returnCard(Card card) => throw StateError('cannot remove cards from here');
}

class WastePile ... implements Pile {
  ...
  @override
  void returnCard(Card card) {
    card.priority = _cards.indexOf(card);
    _fanOutTopCards();
  }
}

class FoundationPile ... implements Pile {
  ...
  @override
  void returnCard(Card card) {
    card.position = position;
    card.priority = _cards.indexOf(card);
  }
}

class TableauPile ... implements Pile {
  ...
  @override
  void returnCard(Card card) {
    final index = _cards.indexOf(card);
    card.position =
        index == 0 ? position : _cards[index - 1].position + _fanOffset;
    card.priority = index;
  }
}
```

Now, putting this all together, the `Card`'s `onDragEnd` method will look like this:

```dart
  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        return;
      }
    }
    pile!.returnCard(this);
  }
```

Ok, that was quite a lot of work -- but if you run the game now, you'd be able to move the cards
properly from one pile to another, and they will never go where they are not supposed to go. The
only thing that remains is to be able to move multiple cards at once between tableau piles. So take
a short break, and then on to the next section!


### 4. Moving a run of cards

In this section we will be implementing the necessary changes to allow us to move small stacks of
cards between the tableau piles. Before we begin, though, we need to make a small fix first.

You have probably noticed when running the game in the previous section that the cards in the
tableau piles clamp too closely together. That is, they are at the correct distance when they face
down, but they should be at a larger distance when they face up, which is not currently the case.
This makes it really difficult to see which cards are available for dragging.

So, let's head over into the `TableauPile` class and create a new method `layOutCards()`, whose job
would be to ensure that all cards currently in the pile have the right positions:

```dart
  final Vector2 _fanOffset1 = Vector2(0, KlondikeGame.cardHeight * 0.05);
  final Vector2 _fanOffset2 = Vector2(0, KlondikeGame.cardHeight * 0.20);

  void layOutCards() {
    if (_cards.isEmpty) {
      return;
    }
    _cards[0].position.setFrom(position);
    for (var i = 1; i < _cards.length; i++) {
      _cards[i].position
        ..setFrom(_cards[i - 1].position)
        ..add(_cards[i - 1].isFaceDown ? _fanOffset1 : _fanOffset2);
    }
  }
```

Make sure to call this method at the end of `removeCard()`, `returnCard()`, and `acquireCard()` --
replacing any current logic that handles card positioning.

Another problem that you may have noticed is that for taller card stacks it becomes hard to place a
card there. This is because our logic for determining in which pile the card is being dropped checks
whether the center of the card is inside any of the `TableauPile` components -- but those components
have only the size of a single card! To fix this inconsistency, all we need is to declare that the
height of the tableau pile is at least as tall as all the cards in it, or even higher. Add this line
at the end of the `layOutCards()` method:

```dart
    height = KlondikeGame.cardHeight * 1.5 + _cards.last.y - _cards.first.y;
```

The factor `1.5` here adds a little bit extra space at the bottom of each pile. You can temporarily
turn the debug mode on to see the hitboxes.

Ok, let's get to our main topic: how to move a stack of cards at once.

First thing that we're going to add is the list of `attachedCards` for every card. This list will
be non-empty only when the card is being dragged while having other cards on top. Add the following
declaration to the `Card` class:

```dart
  final List<Card> attachedCards = [];
```

Now, in order to create this list in `onDragStart`, we need to query the `TableauPile` for the list
of cards that are on top of the given card. Let's add such a method into the `TableauPile` class:

```dart
  List<Card> cardsOnTop(Card card) {
    assert(card.isFaceUp && _cards.contains(card));
    final index = _cards.indexOf(card);
    return _cards.getRange(index + 1, _cards.length).toList();
  }
```

While we are in the `TableauPile` class, let's also update the `canMoveCard()` method to allow
dragging cards that are not necessarily on top:

```dart
  @override
  bool canMoveCard(Card card) => card.isFaceUp;
```

Heading back into the `Card` class, we can use this method in order to populate the list of
`attachedCards` when the card starts to move:

```dart
  @override
  void onDragStart(DragStartEvent event) {
    if (pile?.canMoveCard(this) ?? false) {
      _isDragging = true;
      priority = 100;
      if (pile is TableauPile) {
        attachedCards.clear();
        final extraCards = (pile! as TableauPile).cardsOnTop(this);
        for (final card in extraCards) {
          card.priority = attachedCards.length + 101;
          attachedCards.add(card);
        }
      }
    }
  }
```

Now all we need to do is to make sure that the attached cards are also moved with the main card in
the `onDragUpdate` method:

```dart
  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final cameraZoom = (findGame()! as FlameGame)
        .firstChild<CameraComponent>()!
        .viewfinder
        .zoom;
    final delta = event.delta / cameraZoom;
    position.add(delta);
    attachedCards.forEach((card) => card.position.add(delta));
  }
```

This does the trick, almost. All that remains is to fix any loose ends. For example, we don't want
to let the user drop a stack of cards onto a foundation pile, so let's head over into the
`FoundationPile` class and modify the `canAcceptCard()` method accordingly:

```dart
  @override
  bool canAcceptCard(Card card) {
    final topCardRank = _cards.isEmpty ? 0 : _cards.last.rank.value;
    return card.suit == suit &&
        card.rank.value == topCardRank + 1 &&
        card.attachedCards.isEmpty;
  }
```

Secondly, we need to properly take care of the stack of card as it is being dropped into a tableau
pile. So, go back into the `Card` class and update its `onDragEnd()` method to also move the
attached cards into the pile, and the same when it comes to returning the cards into the old pile:

```dart
  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        if (attachedCards.isNotEmpty) {
          attachedCards.forEach((card) => dropPiles.first.acquireCard(card));
          attachedCards.clear();
        }
        return;
      }
    }
    pile!.returnCard(this);
    if (attachedCards.isNotEmpty) {
      attachedCards.forEach((card) => pile!.returnCard(card));
      attachedCards.clear();
    }
  }
```

Well, this is it! The game is now fully playable. Press the button below to see what the resulting
code looks like, or to play it live. In the next section we will discuss how to make it more
animated with the help of effects.

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step4
:show: popup code
```
