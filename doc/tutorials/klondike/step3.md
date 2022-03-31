# Cards

In this chapter we will begin implementing the most visible component in the
game -- the `Card` component, which corresponds to a single real-life card.
There will be 52 `Card` instances in the game.

Each card is described by its `rank` and `suit`. Rank 1 is an Ace, ranks 2-10
are self-explanatory, rank 11 is Jack, 12 is Queen, and 13 is King. There are
also four suits: hearts, diamonds, clubs, and spades.

The rank and the suit are simple properties of a card, they aren't components,
so we need to make a decision on how to represent them. There are several
possibilities: either as a simple `int`, or as an `enum`, or as objects. The
choice will depend on what operations we need to perform with them. For the
rank, we will need to be able to tell whether one rank is one higher/lower than
another rank. Also, we need to produce the text label and a sprite corresponding
to the given rank. For suits, we need to know whether two suits are of different
colors, and also produce a text label and a sprite. Given these requirements,
I decided to represent them as singleton objects.


## Suit

Create file `suit.dart` and add the following implementation:

```dart
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';

@immutable
class Suit {
  factory Suit.fromInt(int index) {
    assert(index >= 0 && index <= 3);
    return _singletons[index];
  }

  Suit._(this.value, this.label, double x, double y, double w, double h)
      : sprite = Sprite(
          Flame.images.fromCache('klondike-sprites.png'),
          srcPosition: Vector2(x, y),
          srcSize: Vector2(w, h),
        );

  static late final List<Suit> _singletons = [
    Suit._(0, '♥', 1176, 17, 172, 183),
    Suit._(1, '♦', 973, 14, 177, 182),
    Suit._(2, '♣', 974, 226, 184, 172),
    Suit._(3, '♠', 1178, 220, 176, 182),
  ];

  final int value;
  final String label;
  final Sprite sprite;

  /// Hearts and Diamonds are red, while Clubs and Spades are black.
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
}
```

First, we declare the class as `@immutable`, which is really just a hint for
us that the objects of this class should not be modified after creation.

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
symbol on the canvas. Note that we base the sprite object on an image which
we loaded earlier into the global cache.
```dart
  Suit._(this.value, this.label, double x, double y, double w, double h)
      : sprite = Sprite(
          Flame.images.fromCache('klondike-sprites.png'),
          srcPosition: Vector2(x, y),
          srcSize: Vector2(w, h),
        );
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
  bool get isRed => value <= 1;
  bool get isBlack => value >= 2;
```


## Rank

The `Rank` class is very similar to `Suit`. The only difference is that `Rank`
contains two sprites instead of one, separately for ranks of "red" and "black"
colors.

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
  )   : redSprite = Sprite(
          Flame.images.fromCache('klondike-sprites.png'),
          srcPosition: Vector2(x1, y1),
          srcSize: Vector2(w, h),
        ),
        blackSprite = Sprite(
          Flame.images.fromCache('klondike-sprites.png'),
          srcPosition: Vector2(x2, y2),
          srcSize: Vector2(w, h),
        );

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

  final int value;
  final String label;
  final Sprite redSprite;
  final Sprite blackSprite;
}
```


## Card component

Now that we have the `Rank` and the `Suit` classes, we can finally start
implementing the `Card` component. Start simple:
```dart
import 'package:flame/components.dart';
import '../../step2/klondike_game.dart';
import '../rank.dart';
import '../suit.dart';

class Card extends PositionComponent {
  Card(this.rank, this.suit)
      : super(size: Vector2(KlondikeGame.cardWidth, KlondikeGame.cardHeight));

  final Rank rank;
  final Suit suit;
  bool isFaceUp = false;
}
```




```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step3
:show: popup code
```

[spritecow.com]: http://www.spritecow.com/
