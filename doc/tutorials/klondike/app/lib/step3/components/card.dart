import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../klondike_game.dart';
import '../rank.dart';
import '../suit.dart';

class Card extends PositionComponent {
  Card(this.rank, this.suit) : super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;

  bool get isFaceUp => _faceUp;
  bool _faceUp = false;

  void flipUp() => _faceUp = true;
  void flipDown() => _faceUp = false;
  void flip() => _faceUp = !_faceUp;

  @override
  String toString() => rank.label + suit.label;

  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffDBCF58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, KlondikeGame.cardWidth, KlondikeGame.cardHeight),
    const Radius.circular(KlondikeGame.cardRadius),
  );
  static final RRect backRectInner = cardRect.deflate(40);
  static late final Sprite backSprite = _getSprite(1367, 6, 357, 501);

  void _renderBack(Canvas canvas) {
    canvas.drawRRect(cardRect, backBackgroundPaint);
    canvas.drawRRect(cardRect, backBorderPaint1);
    canvas.drawRRect(backRectInner, backBorderPaint2);
    backSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint frontBorderPaint = Paint()
    ..color = const Color(0xffcdf3f2)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static late final Sprite jackSprite = _getSprite(81, 565, 562, 488);
  static late final Sprite queenSprite = _getSprite(717, 541, 486, 515);
  static late final Sprite kingSprite = _getSprite(1305, 532, 407, 549);

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRect, frontBackgroundPaint);
    canvas.drawRRect(cardRect, frontBorderPaint);

    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    const rankAnchor = Anchor(0.1, 0.08);
    const suitAnchor = Anchor(0.1, 0.18);
    _drawSprite(canvas, rankSprite, rankAnchor);
    _drawSprite(canvas, suitSprite, suitAnchor, scale: 0.5);
    _drawSprite(canvas, rankSprite, rankAnchor, rotate: true);
    _drawSprite(canvas, suitSprite, suitAnchor, scale: 0.5, rotate: true);
    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, Anchor.center, scale: 2);
        break;
      case 2:
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.25), rotate: true);
        break;
      case 3:
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.2));
        _drawSprite(canvas, suitSprite, Anchor.center);
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.2), rotate: true);
        break;
      case 4:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25), rotate: true);
        break;
      case 5:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25), rotate: true);
        _drawSprite(canvas, suitSprite, Anchor.center);
        break;
      case 6:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.25), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.25), rotate: true);
        break;
      case 7:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.35));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2), rotate: true);
        break;
      case 8:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.35));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.5));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.35), rotate: true);
        break;
      case 9:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.3));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.4));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.4));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.4), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.4), rotate: true);
        break;
      case 10:
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2));
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.3));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.4));
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.4));
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.2), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.5, 0.3), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.3, 0.4), rotate: true);
        _drawSprite(canvas, suitSprite, const Anchor(0.7, 0.4), rotate: true);
        break;
      case 11:
        _drawSprite(canvas, jackSprite, Anchor.center);
        break;
      case 12:
        _drawSprite(canvas, queenSprite, Anchor.center);
        break;
      case 13:
        _drawSprite(canvas, kingSprite, Anchor.center);
        break;
    }
  }

  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    Anchor anchor, {
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
      position: anchor * size,
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }
}

Sprite _getSprite(double x, double y, double w, double h) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(w, h),
  );
}
