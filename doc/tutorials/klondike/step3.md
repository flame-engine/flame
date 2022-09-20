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
implementing the **Card** component. Create file `components/card.dart` and
declare the `Card` class extending from the `PositionComponent`:

```dart
class Card extends PositionComponent {}
```

The constructor of the class will take integer rank and suit, and make the
card initially facing down. Also, we initialize the size of the component to
be equal to the `cardSize` constant defined in the `KlondikeGame` class:

```dart
  Card(int intRank, int intSuit)
      : rank = Rank.fromInt(intRank),
        suit = Suit.fromInt(intSuit),
        _faceUp = false,
        super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;
  bool _faceUp;
```

The `_faceUp` property is private (indicated by the underscore) and non-final,
meaning that it can change during the lifetime of a card. We should create some
public accessors and mutators for this variable:

```dart
  bool get isFaceUp => _faceUp;
  void flip() => _faceUp = !_faceUp;
```

Lastly, let's add a simple `toString()` implementation, which may turn out to
be useful when we need to debug the game:

```dart
  @override
  String toString() => rank.label + suit.label; // e.g. "Q♠" or "10♦"
```

Before we proceed with implementing the rendering, we need to add some cards
into the game. Head over to the `KlondikeGame` class and add the following at
the bottom of the `onLoad` method:

```dart
    final random = Random();
    for (var i = 0; i < 7; i++) {
      for (var j = 0; j < 4; j++) {
        final card = Card(random.nextInt(13) + 1, random.nextInt(4))
          ..position = Vector2(100 + i * 1150, 100 + j * 1500)
          ..addToParent(world);
        if (random.nextDouble() < 0.9) { // flip face up with 90% probability
          card.flip();
        }
      }
    }
```

This snippet is a temporary code -- we will remove it in the next chapter --
but for now it lays down 28 random cards on the table, most of them facing up.


### Rendering

In order to be able to see a card, we need to implement its `render()` method.
Since the card has two distinct states -- face up or down -- we will
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


### renderBack()

Since rendering the back of a card is simpler, we will do it first.

The `render()` method of a `PositionComponent` operates in a local coordinate
system, which means we don't need to worry about where the card is located on
the screen. This local coordinate system has the origin at the top-left corner
of the component, and extends to the right by `width` and down by `height`
pixels.

There is a lot of artistic freedom in how to draw the back of a card, but my
implementation contains a solid background, a border, a flame logo in the
middle, and another decorative border:

```dart
  void _renderBack(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }
```

The most interesting part here is the rendering of a sprite: we want to
render it in the middle (`size/2`), and we use `Anchor.center` to tell the
engine that we want the *center* of the sprite to be at that point.

Various properties used in the `_renderBack()` method are defined as follows:

```dart
  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    KlondikeGame.cardSize.toRect(),
    const Radius.circular(KlondikeGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  static late final Sprite flameSprite = klondikeSprite(1367, 6, 357, 501);
```

I declared these properties as static because they will all be the same across
all 52 card objects, so we might as well save some resources by having them
initialized only once.


### renderFront()

When rendering the face of a card, we will follow the standard card design: the
rank and the suit in two opposite corners, plus the number of pips equal to the
rank value. The court cards (jack, queen, king) will have special images in the
center.

As before, we begin by declaring some constants that will be used for rendering.
The background of a card will be black, whereas the border will be different
depending on whether the card is of a "red" suit or "black":

```dart
  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color(0xff7ab2e8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
```

Next, we also need the images for the court cards:

```dart
  static late final Sprite redJack = klondikeSprite(81, 565, 562, 488);
  static late final Sprite redQueen = klondikeSprite(717, 541, 486, 515);
  static late final Sprite redKing = klondikeSprite(1305, 532, 407, 549);
```

Note that I'm calling these sprites `redJack`, `redQueen`, and `redKing`. This
is because, after some trial, I found that the images that I have don't look
very well on black-suit cards. So what I decided to do is to take these images
and *tint* them with a blueish hue. Tinting of a sprite can be achieved by
using a paint with `colorFilter` set to the specified color and the `srcATop`
blending mode:

```dart
  static final blueFilter = Paint()
    ..colorFilter = const ColorFilter.mode(
      Color(0x880d8bff),
      BlendMode.srcATop,
    );
  static late final Sprite blackJack = klondikeSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static late final Sprite blackQueen = klondikeSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static late final Sprite blackKing = klondikeSprite(1305, 532, 407, 549)
    ..paint = blueFilter;
```

Now we can start coding the render method itself. First, draw the background
and the card border:

```dart
  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      suit.isRed ? redBorderPaint : blackBorderPaint,
    );
  }
```

In order to draw the rest of the card, I need one more helper method. This
method will draw the provided sprite on the canvas at the specified place (the
location is relative to the dimensions of the card). The sprite can be
optionally scaled. In addition, if flag `rotate=true` is passed, the sprite
will be drawn as if it was rotated 180º around the center of the card:

```dart
  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }
```

Let's draw the rank and the suit symbols in the corners of the card. Add the
following to the `_renderFront()` method:

```dart
    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    _drawSprite(canvas, rankSprite, 0.1, 0.08);
    _drawSprite(canvas, rankSprite, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5, rotate: true);
```

The middle of the card is rendered in the same manner: we will create a big
switch statement on the card's rank, and draw pips accordingly. The code
below may seem long, but it is actually quite repetitive and consists only
of drawing various sprites in different places on the card's face:

```dart
    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, 0.5, 0.5, scale: 2.5);
        break;
      case 2:
        _drawSprite(canvas, suitSprite, 0.5, 0.25);
        _drawSprite(canvas, suitSprite, 0.5, 0.25, rotate: true);
        break;
      case 3:
        _drawSprite(canvas, suitSprite, 0.5, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        _drawSprite(canvas, suitSprite, 0.5, 0.2, rotate: true);
        break;
      case 4:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 5:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        break;
      case 6:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        break;
      case 7:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        break;
      case 8:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.35, rotate: true);
        break;
      case 9:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
        break;
      case 10:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.3, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
        break;
      case 11:
        _drawSprite(canvas, suit.isRed? redJack : blackJack, 0.5, 0.5);
        break;
      case 12:
        _drawSprite(canvas, suit.isRed? redQueen : blackQueen, 0.5, 0.5);
        break;
      case 13:
        _drawSprite(canvas, suit.isRed? redKing : blackKing, 0.5, 0.5);
        break;
    }
```

And this is it with the rendering of the `Card` component. If you run the code
now, you would see four rows of cards neatly spread on the table. Refreshing
the page will lay down a new set of cards. Remember that we have laid these
cards in this way only temporarily, in order to be able to check that rendering
works properly.

In the next chapter we will discuss how to implement interactions with the
cards, that is, how to make them draggable and tappable.

```{flutter-app}
:sources: ../tutorials/klondike/app
:page: step3
:show: popup code
```

[spritecow.com]: http://www.spritecow.com/
