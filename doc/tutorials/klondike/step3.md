# Cards

In this chapter we will begin implementing the most visible component in the
game -- the **Card** component, which corresponds to a single real-life card.
There will be 52 `Card` objects in the game.

Each card has a **rank** (from 1 to 13, where 1 is an Ace, and 13 is a King)
and a **suit** (from 0 to 3: hearts ♥, diamonds ♦, clubs ♣, and spades ♠).
Also, each card will have a boolean flag **faceUp**, which controls whether
the card is currently facing up or down. This property is important both for
rendering, and for certain aspects of the gameplay logic.

The rank and the suit are simple properties of a card, they aren't components,
so we need to make a decision on how to represent them. There are several
possibilities: either as a simple `int`, or as an `enum`, or as objects. The
choice will depend on what operations we need to perform with them. For the
rank, we will need to be able to tell whether one rank is one higher/lower than
another rank. Also, we need to produce the text label and a sprite corresponding
to the given rank. For suits, we need to know whether two suits are of different
colors, and also produce a text label and a sprite. Given these requirements,
I decided to represent both `Rank` and `Suit` as classes.


## Suit

Create file `suit.dart` and declare an `@immutable class Suit` there, with no
parent. The `@immutable` annotation here is just a hint for us that the objects
of this class should not be modified after creation.

Next, we define the factory constructor for the class: `Suit.fromInt(i)`. We
use a factory constructor here in order to enforce the singleton pattern for
the class: instead of creating a new object every time, we are returning one
of the pre-built objects that we store in the `_singletons` list:
```dart
  factory Suit.fromInt(int index) {
    assert(index >= 0 && index <= 3);
    return _singletons[index];
  }
```

After that, there is a private constructor `Suit._()`. This constructor
initializes the main properties of each `Suit` object: the numeric value, the
string label, and the sprite object which we will later use to draw the suit
symbol on the canvas. The sprite object is initialized using the
`klondikeSprite()` function that we created in the previous chapter:
```dart
  Suit._(this.value, this.label, double x, double y, double w, double h)
      : sprite = klondikeSprite(x, y, w, h);

  final int value;
  final String label;
  final Sprite sprite;
```

Then comes the static list of all `Suit` objects in the game. Note that we
define it as `late`, meaning that it will be only initialized the first time
it is needed. This is important: as we seen above, the constructor tries to
retrieve an image from the global cache, so it can only be invoked after the
image is loaded into the cache.
```dart
  static late final List<Suit> _singletons = [
    Suit._(0, '♥', 1176, 17, 172, 183),
    Suit._(1, '♦', 973, 14, 177, 182),
    Suit._(2, '♣', 974, 226, 184, 172),
    Suit._(3, '♠', 1178, 220, 176, 182),
  ];
```
The last four numbers in the constructor are the coordinates of the sprite
image within the spritesheet `klondike-sprites.png`. If you're wondering how I
obtained these numbers, the answer is that I used a free online service
[spritecow.com] -- it's a handy tool for locating sprites within a spritesheet.

Lastly, I have simple getters to determine the "color" of a suit. This will be
needed later when we need to enforce the rule that cards can only be placed
into columns by alternating colors.
```dart
  /// Hearts and Diamonds are red, while Clubs and Spades are black.
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
```


## Rank

The `Rank` class is very similar to `Suit`. The main difference is that `Rank`
contains two sprites instead of one, separately for ranks of "red" and "black"
colors. The full code for the `Rank` class is as follows:

```dart
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';

@immutable
class Rank {
  factory Rank.of(int value) {
    assert(value >= 1 && value <= 13);
    return _singletons[value - 1];
  }

  Rank._(
    this.value,
    this.label,
    double x1,
    double y1,
    double x2,
    double y2,
    double w,
    double h,
  )   : redSprite = klondikeSprite(x1, y1, w, h),
        blackSprite = klondikeSprite(x2, y2, w, h);

  final int value;
  final String label;
  final Sprite redSprite;
  final Sprite blackSprite;

  static late final List<Rank> _singletons = [
    Rank._(1, 'A', 335, 164, 789, 161, 120, 129),
    Rank._(2, '2', 20, 19, 15, 322, 83, 125),
    Rank._(3, '3', 122, 19, 117, 322, 80, 127),
    Rank._(4, '4', 213, 12, 208, 315, 93, 132),
    Rank._(5, '5', 314, 21, 309, 324, 85, 125),
    Rank._(6, '6', 419, 17, 414, 320, 84, 129),
    Rank._(7, '7', 509, 21, 505, 324, 92, 128),
    Rank._(8, '8', 612, 19, 607, 322, 78, 127),
    Rank._(9, '9', 709, 19, 704, 322, 84, 130),
    Rank._(10, '10', 810, 20, 805, 322, 137, 127),
    Rank._(11, 'J', 15, 170, 469, 167, 56, 126),
    Rank._(12, 'Q', 92, 168, 547, 165, 132, 128),
    Rank._(13, 'K', 243, 170, 696, 167, 92, 123),
  ];
}
```


## Card component

Now that we have the `Rank` and the `Suit` classes, we can finally start
implementing the `Card` component:
```dart
import 'package:flame/components.dart';
import '../klondike_game.dart';
import '../rank.dart';
import '../suit.dart';

class Card extends PositionComponent {
  Card(this.rank, this.suit) : super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;

  bool get isFaceUp => _faceUp;
  bool _faceUp = false;
  void flip() => _faceUp = !_faceUp;

  @override
  String toString() => rank.label + suit.label;
}
```

In order to be able to see a `Card`, we need to implement its `render()`
method. Since the card has two distinct states -- face up or down -- we will
implement rendering for these two states separately. Add the following methods
into the `Card` class:
```dart
  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  void _renderFront(Canvas canvas) {}
  void _renderBack(Canvas canvas) {}
```


```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step3
:show: popup code
```

[spritecow.com]: http://www.spritecow.com/
