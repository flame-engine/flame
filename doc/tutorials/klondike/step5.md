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
many game-wide values. Let ius call our value `klondikeDraw`. In your class declaration add the
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
```{note}
It would be a mistake to write `_whereCardStarted = position;`. In Dart, that would just
copy a reference &mdash; so `_whereCardStarted` would point to the same data as `position` while the
drag occurred and the position of the card changed. We can get around this by copying the card's
**current** X and Y co-ordinates into a **new** `Vector2` object.
```

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
after a valid drag-and-drop.

## Animating a card-flip

Flutter and Flame do not support 3-D effects (as of 2023), but we can emulate them. To make a card
look as if it is turning over, we will shrink the width of the back-view, switch to the front view
and expand back to full width. The code uses quite a few features of Effects and EffectControllers:
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
other cards in the neighbourhood. That value cannot always be saved and restored because we may
not know what the card's priority should be in whatever `Pile` is receiving it. So we have made
sure that the receiver is always called in the `onComplete:` option, using a method that will
adjust the positions and priorities of the cards in the pile.

Last but not least, in the preceding code, notice the use of the variable `_isAnimatedFlip`.
This is a `bool` variable defined and initialised near the start of class `Card` in file
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
animated flip is keeping the card face-down while the first half of an animated flip is occurring.

## Model and View

Clearly the card cannot be in two states at once: it is not Schrödinger's cat. We can solve the
dilemma by adopting two definitions of "face-up": a Model and a View type. The View version is used
in rendering and animation (i.e. what appears on the screen) and the Model version in the logic
of the game, the gameplay and its error-checks. That way, we do not have to revise all the logic
of the Piles in this game in order to animate some of it. A more complex game might benefit from
separating the Model and the View during the design and early coding stages &mdash; even into
separate classes.

In the Klondike Tutorial game we are still having to trigger a Model update in the `onComplete:`
callback of the flip animation. It might be nice, for impatient or rapid-fingered players, to
transfer a card from Stock Pile to Waste Pile instaneously, in the Model, leaving the animation
to catch up later, with no `onComplete:` callback. That way, you could flip through the Stock Pile
very rapidly, by tapping quickly. However, that is beyond the scope of this Tutorial.

## More animations of moves

------------???

## Ending and restarting the game

As it stands, there is no easy way to finish the Klondike Tutorial game and start another, even if
you have won. We can only close the app and start it again. And there is no "reward" for winning.


------------???

Well, this is it! The game is now more playable. We could do more, but this game **is** a Tutorial
above all else. Press the button below to see what the resulting code looks like, or to play it
live. But it is also time to have a look at the Ember Tutorial!

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step5
:show: popup code
```
