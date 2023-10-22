# 5. Additional features

In this chapter we will be showing various ways to make the Klondike game more fun and easier to
play. As it is now, the cards move from one pile to another immediately, which looks unnatural, so
we will also be working on ways to animate that and smooth it out, for which we will be introducing
Effect and EffectController components.

## The Klondike draw

The Klondike patience game (or solitaire game in the USA) has two main variants: Draw 3 and Draw 1. Currently the Klondike Flame Game is Draw 3, which is a lot more difficult than Draw 1, although we
did learn how to code fanning out 3 cards horizontally when thay are drawn from the Stock. The
difficulty is that, although you can see 3 cards, you can only move one of them and that will change
the "phase" of other cards. So you have to handle that - not easy.

In Klondike Draw 1 just one card at a time is drawn from the Stock and shown, so every card in it is
available, and you can go through the Stock as many times as you like, just as in Klondike Draw 3.

So how do we implement Klondike Draw 1? Clearly only the Stock and Waste piles are involved, so
maybe we should have KlondikeGame provide a value 1 or 3 to each of them. They both have code for
constructors, so we could just add an extra parameter to that code, but in Flame there is another
way, which works even if your component has a default constructor (no code for it) or your game has
lots of game-wide values. Let call our value `klondikeDraw` In your class declaration add the
`HasGameReference<MyGame>' mixin, then write `game.klondikeDraw` wherever you need the value 1 or 3.
For class StockPile we will have:
'''dart
class StockPile extends PositionComponent
        with TapCallbacks, HasGameReference<KlondikeGame> implements Pile {
'''
and
'''dart
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
'''

For class WastePile we will have:
```dart
class WastePile extends PositionComponent with HasGameReference<KlondikeGame>
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
effect, such as start moving a card quickly and then slow down as it reaches its destination.

To move a card, we will add a `goTo()` method to the `Card` class. It will require a `position` to
go to and either a `time:` or a `speed:` parameter (but not both!). Speed is in card widths per
second. Optional parameters are `start:` (default zero), `curve:` (default `Curves.easeOutQuad`)
and `onComplete:` (default `null`, i.e. no callback when the move finishes). Usually we will
provide a callback, because a bit of gameplay must be done **after** the animated move. The default
`curve:` parameter gives us a fast-in/slow-out move, much as a human player would do. So the
following code is added to the end of the `Card` class:
```dart
  void goTo(Vector2 position, {
            double? time,
            double? speed,
            double  start = 0.0,
            Curve   curve = Curves.easeOutQuad,
            VoidCallback? onComplete = null})
  {
    // Must provide either time or speed (in widths per sec), but not both.
    assert((time == null) ^ (speed == null));
    double dt = time != null ? time
                : (position - this.position).length / (speed! * this.size.x);
    this.add(
      MoveToEffect(
        position,
        EffectController(duration: dt, startDelay: start, curve: curve),
        onComplete: () {onComplete?.call();},
      )
    );
  }
```
Notice the assert line: this has an exclusive-OR condition (`^`) to ensure that the caller provides
either `time:` or `speed:` but not both.

To make this code compile we need to import `'package:flutter/animation.dart'` and
`'package:flame/effects.dart'` at the top of the `components/card.dart` file. That done, we can
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
      // Copy each co-ord, else _whereCardStarted changes when position does.
      _whereCardStarted = Vector2(position.x, position.y);
      if (pile is TableauPile) {
```
Note that it would be a mistake to write `\_whereCardStarted = position;`. In Dart, that would just
copy a reference -- so `\_whereCardStarted` would point to the same data as `position` while the
drag occurred and the position of the card changed. We can get around this by copying the card's
current X and Y co-ordinates into a new `Vector2` object.

To animate cards being returned to their original piles after an invalid drag-and-drop, we replace
five lines at the end of the `onDragEnd()` method with:
```dart
    // Invalid drop (middle of nowhere, invalid pile or invalid card for pile).
    this.goTo(_whereCardStarted, speed: 10.0,
         onComplete: () {pile!.returnCard(this);});
    if (attachedCards.isNotEmpty) {
      attachedCards.forEach((card) {
        Vector2 offset = card.position - this.position;
        card.goTo(_whereCardStarted + offset, speed: 10.0,
                  onComplete: () {pile!.returnCard(card);});
      });
      attachedCards.clear();
    }
```
Notice how the `onComplete:` parameters are used to return each card to the pile where it started.
It will then be added back to that pile's list of contents. Notice also that the list of attached
cards (if any) is cleared immediately, as the animated cards start to move. This does not matter,
because each moving card has a `MoveToEffect` and an `EffectController` added to it and these
contain all the data needed to get the right card to the right place at the right time. Thus
no important information is lost by clearing the attached cards early. Also, by default, the
`MoveToEffect` and `EffectController` in each moving card automatically get detached and deleted
when the show is over.




------------???

Well, this is it! The game is now more playable. We could do more, but this game is a Tutorial above
all. Press the button below to see what the resulting code looks like, or to play it live. But it is
also time to have a look at the Ember Tutorial!

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step5
:show: popup code
```
