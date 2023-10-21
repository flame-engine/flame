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

In Klondike Draw 1 just one card at a time is drawn from the Stock and shown, but you can go
through the Stock as many times as you like, just as in Klondike Draw 3.

------------???

Well, this is it! The game is now more playable. We could do more, but this game is a Tutorial above
all. Press the button below to see what the resulting code looks like, or to play it live. But it is
also time to have a look at the Ember Tutorial!

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step5
:show: popup code
```
