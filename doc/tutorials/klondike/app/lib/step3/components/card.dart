import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../klondike_game.dart';
import '../rank.dart';
import '../suit.dart';

class Card extends PositionComponent {
  Card(this.rank, this.suit)
      : super(size: Vector2(KlondikeGame.cardWidth, KlondikeGame.cardHeight));

  final Rank rank;
  final Suit suit;
  bool isFaceUp = false;

  static final Paint backPaint = Paint()..color = const Color(0xff002123);
  static final Paint borderPaint = Paint()
    ..color = const Color(0xff237489)
    ..style= PaintingStyle.stroke
    ..strokeWidth = 5;
  static final RRect backRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, KlondikeGame.cardWidth, KlondikeGame.cardHeight),
    Radius.circular(KlondikeGame.cardRadius),
  );
  static late final Sprite backSprite = Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(1367, 6),
    srcSize: Vector2(357, 501),
  );

  @override
  void render(Canvas canvas) {
    if (isFaceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  void _renderFront(Canvas canvas) {}

  void _renderBack(Canvas canvas) {
    canvas.drawRRect(backRect, backPaint);
    canvas.drawRRect(backRect, borderPaint);
    backSprite.render(canvas,
      position: Vector2(KlondikeGame.cardWidth/2, KlondikeGame.cardHeight/2),
      anchor: Anchor.center,
    );
  }
}
