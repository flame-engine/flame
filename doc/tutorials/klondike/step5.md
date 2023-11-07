# 5. Additional features

In this chapter we will be showing various ways to make the Klondike game more fun and easier to
play. As it is now, the cards move from one pile to another immediately, which looks unnatural, so
we will also be working on ways to animate that and smooth it out, for which we will be introducing
Effect and EffectController components.


## The Klondike draw

The Klondike patience game (or solitaire game in the USA) has two main variants: Draw 3 and Draw 1.
Currently the Klondike Flame Game is Draw 3, which is a lot more difficult than Draw 1, because
although you can see 3 cards, you can only move one of them and that move changes the "phase" of
other cards. So different cards are going to become available &mdash; not easy.

In Klondike Draw 1 just one card at a time is drawn from the Stock and shown, so every card in it is
available, and you can go through the Stock as many times as you like, just as in Klondike Draw 3.

So how do we implement Klondike Draw 1? Clearly only the Stock and Waste piles are involved, so
maybe we should have KlondikeGame provide a value 1 or 3 to each of them. They both have code for
constructors, so we could just add an extra parameter to that code, but in Flame there is another
way, which works even if your component has a default constructor (no code for it) or your game has
many game-wide values. Let us call our value `klondikeDraw`. In your class declaration add the
`HasGameReference<MyGame>` mixin, then write `game.klondikeDraw` wherever you need the value 1 or 3.
For class StockPile we will have:

```dart
class StockPile extends PositionComponent
    with TapCallbacks, HasGameReference<KlondikeGame>
    implements Pile {
```

and

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
      for (var i = 0; i < game.klondikeDraw; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.flip();
          wastePile.acquireCard(card);
        }
      }
    }
  }
```

For class WastePile we will have:

```dart
class WastePile extends PositionComponent
    with HasGameReference<KlondikeGame>
    implements Pile {
```

and

```dart
  void _fanOutTopCards() {
    if (game.klondikeDraw == 1) {   // No fan-out in Klondike Draw 1.
      return;
    }
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

That makes the Stock and Waste piles play either Klondike Draw 1 or Klondike Draw 3, but how do you
tell them which variant to play? For now, we will add a place-holder to the KlondikeGame class.
We just comment out whichever one we do not want and then rebuild.

```dart
  // final int klondikeDraw = 3;
  final int klondikeDraw = 1;
```

This is fine as a temporary measure, when we have not yet decided how to handle some aspect of
our design, but ultimately we will have to provide some kind of **input** for the player to choose
which flavor of Klondike to play, such as a menu screen, a settings screen or a button. Flame can
incorporate Flutter widgets into a game and the next Tutorial (Ember) shows how to add a menu
widget, as its final step.


## Making cards move

In Flame, if we need a component to do something, we use an `Effect` - a special component that can
attach to another component, such as a card, and modify its properties. That includes any kind of
motion (or change of `position`). We also need an `EffectController`, which provides timing for an
effect: when to start, how long to go for and what `Curve` to follow. The latter is not a curve in
space. It is a time-curve that specifies accelerations and decelerations during the time of the
effect, such as start moving a card quickly and then slow down as it approaches its destination.

To move a card, we will add a `doMove()` method to the `Card` class. It will require a `to` location
to go to. Optional parameters are `speed:` (default 10.0), `start:` (default zero),
`curve:` (default `Curves.easeOutQuad`) and `onComplete:` (default `null`, i.e. no callback when
the move finishes). Speed is in card widths per second. Usually we will provide a callback, because
a bit of gameplay must be done **after** the animated move. The default `curve:` parameter gives us
a fast-in/slow-out move, much as a human player would do. So the following code is added to the
end of the `Card` class:

```dart
  void doMove(
    Vector2 to, {
    double speed = 10.0,
    double start = 0.0,
    Curve curve = Curves.easeOutQuad,
    VoidCallback? onComplete,
  }) {
    assert(speed > 0.0, 'Speed must be > 0 widths per second');
    final dt = (to - position).length / (speed * size.x);
    assert(dt > 0.0, 'Distance to move must be > 0');
    priority = 100;
    add(
      MoveToEffect(
        to,
        EffectController(duration: dt, startDelay: start, curve: curve),
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }
```

To make this code compile we need to import `'package:flame/effects.dart'` and
`'package:flutter/animation.dart'` at the top of the `components/card.dart` file. That done, we can
start using the new method to return the card(s) gracefully to where they came from, after being
dropped in an invalid position. First, we need a private data item to store a card's position when
a drag-and-drop started. So let us insert new lines in two places as shown below:

```dart
  bool _isDragging = false;
  Vector2 _whereCardStarted = Vector2(0, 0);

  final List<Card> attachedCards = [];
```

```dart
      _isDragging = true;
      priority = 100;
      // Copy each co-ord, else _whereCardStarted changes as the position does.
      _whereCardStarted = Vector2(position.x, position.y);
      if (pile is TableauPile) {
```

It would be a mistake to write `_whereCardStarted = position;` here. In Dart, that would just
copy a reference &mdash; so `_whereCardStarted` would point to the same data as `position` while the
drag occurred and the card's `position` data changed. We can get around this by copying the card's
**current** X and Y co-ordinates into a **new** `Vector2` object.

To animate cards being returned to their original piles after an invalid drag-and-drop, we replace
five lines at the end of the `onDragEnd()` method with:

```dart
    // Invalid drop (middle of nowhere, invalid pile or invalid card for pile).
    doMove(
      _whereCardStarted,
      onComplete: () {
        pile!.returnCard(this);
      },
    );
    if (attachedCards.isNotEmpty) {
      attachedCards.forEach((card) {
        final offset = card.position - position;
        card.doMove(
          _whereCardStarted + offset,
          onComplete: () {
            pile!.returnCard(card);
          },
        );
      });
      attachedCards.clear();
    }
```

In each case, we use the default speed of 10 card-widths per second.
Notice how the `onComplete:` parameters are used to return each card to the pile where it started.
It will then be added back to that pile's list of contents. Notice also that the list of attached
cards (if any) is cleared immediately, as the animated cards start to move. This does not matter,
because each moving card has a `MoveToEffect` and an `EffectController` added to it and these
contain all the data needed to get the right card to the right place at the right time. Thus
no important information is lost by clearing the attached cards early. Also, by default, the
`MoveToEffect` and `EffectController` in each moving card automatically get detached and deleted
by Flame when the show is over.

Some other automatic and animated moves we can try are dealing the cards, flipping cards from Stock
to Waste pile, turning cards over automatically on the tableau piles, and settling cards into place
after a valid drag-and-drop. We will have a look at animating a flip first.


## Animating a card-flip

Flutter and Flame do not yet support 3-D effects (as at October 2023), but we can emulate them.
To make a card look as if it is turning over, we will shrink the width of the back-view, switch
to the front view and expand back to full width. The code uses quite a few features of Effects
and EffectControllers:

```dart
  void turnFaceUp({
    double time = 0.3,
    double start = 0.0,
    VoidCallback? onComplete,
  }) {
    assert(!_isFaceUpView, 'Card must be face-down before turning face-up.');
    assert(time > 0.0, 'Time to turn card over must be > 0');
    _isAnimatedFlip = true;
    anchor = Anchor.topCenter;
    position += Vector2(width / 2, 0);
    priority = 100;
    add(
      ScaleEffect.to(
        Vector2(scale.x / 100, scale.y),
        EffectController(
          startDelay: start,
          curve: Curves.easeOutSine,
          duration: time / 2,
          onMax: () {
            _isFaceUpView = true;
          },
          reverseDuration: time / 2,
          onMin: () {
            _isAnimatedFlip = false;
            _faceUp = true;
            anchor = Anchor.topLeft;
            position -= Vector2(width / 2, 0);
          },
        ),
        onComplete: () {
          onComplete?.call();
        },
      ),
    );
  }
```

So how does all this work? We have a default time of 0.3 seconds for the flip to occur, a start time
and an optional callback on completion &mdash; as before. Now we add a ScaleEffect to the card,
which shrinks it almost to zero width, but leaves the height unchanged. However, that must take
only half the time, then we must switch from the face-down to the face-up view of the card and
expand it back out, also in half the time.

This is where we use some of the fancier parameters of the `EffectController` class. The
`duration:` is set to `time / 2` and we use an `onMax:` callback, with inline code to change the
view to face-up. That callback will happen after `time / 2`, when the `Effect` (whatever it is)
has reached its maximum (i.e. in this case, the view of the card has shrunk to a thin vertical
line). After the switch to face-up view, the EffectController will take the Effect into reverse
for `reverseDuration: time / 2`. Everything is reversed: the view of the card expands and the
`curve:` of time is applied in reverse order. In total, the timing follows a sine curve from
0 to pi, giving a smooth animation in which the width of the card-view is always the projection
into 2-D of its 3-D position. Wow! That's a lot of work for a little EffectController!

We are not there yet! If you were to run just the `add()` part of the code, you would see some
ugly things happening. Yeah, yeah, been there, done that &mdash; when I was preparing this code!
First off, the card shrinks to a line at its left. That is because all cards in this game have
an `Anchor` at `topLeft`, which is the point used to set the card's `position`. We would like
the card to flip around its vertical center-line. Easy, just set `anchor = Anchor.topCenter`
first: that makes the card flip realistically, but it jumps by half a card-width to the left
before flipping.

Long story short, see the lines between `assert(` and `add(` and their reversal in the `onMin:`
callback, which occurs when the Effect is finished, but before the final `onComplete:` callback.
At the beginning, the card's rendering `priority` is set to 100, so that it will ride above all
other cards in the neighborhood. That value cannot always be saved and restored because we may
not know what the card's priority should be in whatever `Pile` is receiving it. So we have made
sure that the receiver is always called in the `onComplete:` option, using a method that will
adjust the positions and priorities of the cards in the pile.

Last but not least, in the preceding code, notice the use of the variable `_isAnimatedFlip`.
This is a `bool` variable defined and initialized near the start of class `Card` in file
`components/card.dart`, along with another new `bool` called `_isFaceUpView`. Initially these
are set `false`, along with the existing `bool _faceUp = false` variable. What is the significance
of these variables? It is **huge**. A few lines further down, we see:

```dart
  @override
  void render(Canvas canvas) {
    if (_isFaceUpView) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }
```

This is the code that makes every card visible on the screen, in either face-up or face-down state.
At the end of Klondike Tutorial Step 4, the `if` statement was `if (_faceUp) {`. This was OK
because all moves of cards were instantaneous (leaving aside drags and drops): any change in the
card's face-up or face-down state could be rendered at the Flame Engine's next `tick` or soon after.
This posed no problem when we started to animate card moves, provided there were no flips involved.
However, when we tapped a non-empty Stock Pile, the executed code was:

```dart
  final card = _cards.removeLast();
  card.flip;
  wastePile.acquireCard(card);
```

And the first thing `wastePile.acquireCard(` does is `assert(card.isFaceUp);`, which fails if an
animated flip is keeping the card face-down while the first half of the flip is occurring.


## Model and View

Clearly the card cannot be in two states at once: it is not Schrödinger's cat! We can resolve the
dilemma by using two definitions of "face-up": a Model type and a View type. The View version is
used in rendering and animation (i.e. what appears on the screen) and the Model version in the logic
of the game, the gameplay and its error-checks. That way, we do not have to revise all the logic
of the Piles in this game in order to animate some of it. A more complex game might benefit from
separating the Model and the View during the design and early coding stages &mdash; even into
separate classes. In this game we are using just a little separation of Model and View. The
`_isAnimatedFlip` variable is `true` while there is an animated flip going on, otherwise `false`,
and the `Card` class's `flip()` function is expanded to:

```dart
  void flip() {
    if (_isAnimatedFlip) {
      // Let the animation determine the FaceUp/FaceDown state.
      _faceUp = _isFaceUpView;
    } else {
      // No animation: flip and render the card immediately.
      _faceUp = !_faceUp;
      _isFaceUpView = _faceUp;
    }
  }
```

In the Klondike Tutorial game we are still having to trigger a Model update in the `onComplete:`
callback of the flip animation. It might be nice, for impatient or rapid-fingered players, to
transfer a card from Stock Pile to Waste Pile instantaneously, in the Model, leaving the animation
in the View to catch up later, with no `onComplete:` callback. That way, you could flip through
the Stock Pile very rapidly, by tapping fast. However, that is beyond the scope of this Tutorial.


## Ending and restarting the game

As it stands, there is no easy way to finish the Klondike Tutorial game and start another, even if
you have won. We can only close the app and start it again. And there is no "reward" for winning.

There are various ways to tackle this, depending on the simplicity or complexity of your game and
on how long the `onLoad()` function is likely to take. They can range from writing your own
GameWidget, to doing a few simple re-initializations in your Game class (i.e. KlondikeGame in this
case).

In the GameWidget case you would supply the Game with a VoidCallback function parameter named
`reset` or `restart`. When the callback is invoked, it would use the Flutter conventions of a
`StatefulWidget` (e.g. `setState(() {});)` to force the widget to be rebuilt and replaced, thus
releasing all references to the current Game instance, its state and all of its memory. There could
also be Flutter code to run a menu or other startup screen.

Re-initialization should be undertaken only if the operations involved are few and simple. Otherwise
coding errors could lead to subtle problems, memory leaks and crashes in your game.
It may be the easiest way to go in Klondike (as it is in the Ember Tutorial).
Basically, we must clear all the card references out of all the `Pile`s and then re-shuffle (or not)
and re-deal, possibly changing from Klondike Draw 3 to Klondike Draw 1 or vice-versa.

Well, that was not as easy as it looked! Re-initializing the `Pile`s and each `Card` was easy
enough &mdash; see the code for the abstract `init()` method in `pile.dart`, its implementation
in each of the Pile Components and the `init()` method in the `Card` class. To activate these, we
add `enum Startup` to `KlondikeGame` and move some of the code from the `onLoad()` method to a
`void init(Startup startType)` method and a `void deal(Startup startType)` where we can have
various types of restart for the game:

- First start, after `onLoad()`,
- Restart with a new deal,
- Restart with the same deal as before,
- Switch between Klondike Draw 1 and Draw 3 and restart with a new deal, and
- Have fun before restarting with a new deal (we'll keep that as a surprise for later).

Here is the first part of the code for starting and restarting the game.

```dart
enum Startup {first, newDeal, sameDeal, changeDraw, haveFun}
```

```dart
    camera.viewfinder.anchor = Anchor.topCenter;

    init(Startup.first);
  } // End of onLoad().

  void init(Startup startType) {
    assert(cards.length == 52, 'There are ${cards.length} cards: should be 52');
    if (startType == Startup.first) {
      deal(Startup.first);
    } else {
      stock.init();
      waste.init();
      foundations.forEach((foundation) => foundation.init());
      piles.forEach((tableau) => tableau.init());
      cards.forEach((card) => card.init());
```

But the difficult bit comes next... Whether the player wins or restarts without winning, we have
52 cards spread around various piles on the screen, some face-up and maybe some face-down. We would
like to animate the deal later, so it would be nice to collect the cards into a neat face-down pile
at top left, in the Stock Pile area. It is not the actual Stock Pile yet, because that gets created
during the deal. Writing a simple little loop to set each `Card` face-down and use its `doMove`
method to make it move independently to the top left fails. It causes one of those "subtle problems"
referred to earlier. The cards all travel at the same speed but arrive at different times. The deal
then produces messy Tableau Piles with several cards out of position. It is better to control the
process in KlondikeGame and make sure that the cards are all in position before the deal starts.
Here is one way of doing that and finishing the `init` method:

```dart
      var nMovingCards = 0;
      for (Card card in cards) {
        if (card.isFaceUp) {
          card.flip();
        }
        if ((card.position - stock.position).length > 1.0) {
          // Move cards that are not already in the Stock Pile.
          nMovingCards++;
          card.doMove(stock.position, onComplete: () {
            nMovingCards--;
            if (nMovingCards == 0) {
              deal(startType);
            }
          },);
        }
      }
    }
  }
```

We check all 52 cards, taking care not to animate any cards that may already be in
the Stock Pile area, because the distance and time to move would then be zero and that would cause
an exception in Flame's MoveToEffect code. We count each moving card as it departs. For a few
milliseconds after the loop terminates `nMovingCards` will be at a maximum, then cards will be
arriving over the next second or so and will be counted off in the `onComplete()` callback code.
When the countdown reaches zero the `deal(startType)` method can be safely called. We use a
similar technique to animate the deal and make sure all 28 cards (i.e. 1 + 2 + 3 + 4 + 5 + 6 + 7
= 28) have been dealt, before constructing the Stock Pile from the remaining 24 cards. This
debugging printout of the deal shows how arrivals can get out of order. The `j` variable is
the Tableau Pile number and `i` is the card's position in the pile.

```dart
/*
flutter: Move done, i 3, j 6, 6♠ 5 moving cards.
flutter: Move done, i 4, j 5, 9♥ 4 moving cards.
flutter: Move done, i 4, j 6, K♥ 3 moving cards.
flutter: Move done, i 5, j 5, Q♣ 2 moving cards.
flutter: Move done, i 5, j 6, 2♠ 1 moving cards.
flutter: Move done, i 6, j 6, 10♠ 0 moving cards.
flutter: Pile 0 [Q♦]
flutter: Pile 1 [J♣, Q♥]
flutter: Pile 2 [5♥, 5♦, J♦]
flutter: Pile 3 [A♠, Q♠, A♥, 5♠]
flutter: Pile 4 [8♦, 10♣, 7♥, 3♥, 4♥]
flutter: Pile 5 [4♠, 8♣, 5♣, 2♥, 9♥, Q♣]
flutter: Pile 6 [4♣, 3♦, K♦, 6♠, K♥, 2♠, 10♠]
*/
```


## Buttons

We are going to use some buttons to activate the various ways of restarting the Klondike Game. First
we extend Flame's `ButtonComponent` to create class `FlatButton`, adapted from a Flat Button which
used to be in Flame's Examples pages. `ButtonComponent` uses two `PositionComponent`s, one for when
the button is in its normal state (up) and one for when it is pressed. The two components are
`mounted` and `rendered` alternately as the user presses the button and releases it. To press the
button, tap and hold it down.

In our button, the two components are the button's outlines - the `buttonDown:` one makes
the outline of the button turn red when it is pressed, because the four button-actions all
end the current game and start another. That is also why they are positioned at the top of the
canvas, above all the cards, where you are less likely to press them accidentally. If you do press
one and have second thoughts, keep pressing and slide away, then the button will have no effect.

The four buttons trigger the restart actions described above and are labelled `New deal`,
`Same deal`, `Draw 1 ⇌ 3` and `Have fun`. Flame also has a `SpriteButtonComponent`, based on two
alternating `Sprite`s, a `HudButtonComponent` and an `AdvancedButtonComponent`. For further types
of buttons and controllers, it would be best to use a Flutter overlay, menu or settings widget and
have access to Flutter's widgets for radio buttons, dropdown lists, sliders, etc. For the purposes
of this Tutorial our FlatButton will do fine.


## More animations of moves

The `Card` class's `doMove()` and `turnFaceUp()` methods have been combined into a doMoveAndFlip()
method, which is used to draw cards from the Stock Pile. The dropping of a card or cards onto a pile
after drag-and-drop also uses `doMove()` to settle the drop more gracefully. Finally, there is a
shortcut to auto-move a card onto its Foundation Pile if it is ready to go out. This adds
`TapCallbacks` to the `Card` class and an `onTapUp()` callback as follows:

```dart
  onTapUp(TapUpEvent event) {
    if (isFaceUp) {
      final suitIndex = suit.value;
      if (game.foundations[suitIndex].canAcceptCard(this)) {
        pile!.removeCard(this);
        doMove(
          game.foundations[suitIndex].position,
          onComplete: () {
            game.foundations[suitIndex].acquireCard(this);
          },
        );
      }
    } else if (pile is StockPile) {
      game.stock.onTapUp(event);
    }
  }
```

If a card is ready to go out, just tap on it and it will move automatically to the correct
Foundation Pile for its suit. This saves a load of dragging-and-dropping when you are close to
winning the game! There is nothing new in the above code, except that if you tap the top card of
the Stock Pile, the `Card` object receives the tap first and forwards it on to the `stock` object.


## Winning the game

You win the game when all cards in all suits, Ace to King, have been moved to the Foundation Piles,
13 cards in each pile. The Klondike Game now has some code to recognize that event: an `isFull` test
added to the `FoundationPile`'s `acquireCard()` method, a callback to `KlondikeGame` and a test as
to whether all four Foundations are full. Here is the code:

```dart
class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(int intSuit, this.checkWin, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final VoidCallback checkWin;

  final Suit suit;
  final List<Card> _cards = [];

  //#region Pile API

  bool get isFull => _cards.length == 13;

```

```dart
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);
    if (isFull) {
      checkWin(); // Get KlondikeGame to check all FoundationPiles.
    }
  }

```

```dart
  void checkWin()
  {
    var nComplete = 0;
    for (final f in foundations) {
      if (f.isFull) {
        nComplete++;
      }
    }
    if (nComplete == foundations.length) {
      letsCelebrate();
    }
  }
```

It is possible to calculate whether you can win from a position of the cards in a Klondike game,
or could have won but missed a vital move. It is even possible to calculate whether the initial
deal is winnable: a percentage of Klondike deals are not. But all that is far beyond the scope
of this Tutorial, so for now it is up to the player to decide whether to keep playing and try to
win &mdash; or give up and press one of the buttons.


The `Have fun` button.

When you win the Klondike Game, the `letsCelebrate()` method puts on a little display. To save you
having to play and win a whole game before you see it &mdash; **and** to test the method, we have
provided the `Have fun` button. Of course a real game could not have such a button...

Well, this is it! The game is now more playable.

We could do more, but this game **is** a Tutorial above all else. Press the button below to see
what the final code looks like, or to play it live.

But it is also time to have a look at the Ember Tutorial!

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step5
:show: popup code
```
