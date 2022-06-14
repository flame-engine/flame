import 'dart:ui';

import 'package:flame/components.dart';

import '../klondike_game.dart';
import '../suit.dart';
import 'card.dart';

class FoundationPile extends PositionComponent {
  FoundationPile(int intSuit, {super.position})
      : suit = Suit.fromInt(intSuit),
        super(size: KlondikeGame.cardSize);

  final Suit suit;
  final List<Card> _cards = [];

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed? const Color(0x36000000) : const Color(0x64000000)
    ..blendMode = BlendMode.luminosity;

  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    _cards.add(card);
  }

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

  /*
  Path _preparePath() {
    const w = KlondikeGame.cardWidth * 0.3;
    final path = Path();
    if (suit.value == 0) {
      path.moveTo(0, -w * 0.75);
      path.cubicTo(w * 1.0, -w * 1.55, 1.7 * w, 0.0 * w, 0, w * 0.95);
      path.cubicTo(-1.7 * w, 0, -w, -w * 1.55, 0, -w * 0.75);
      path.close();
    }
    if (suit.value == 1) {
      path.moveTo(-w, 0);
      path.lineTo(0, -w);
      path.lineTo(w, 0);
      path.lineTo(0, w);
      path.lineTo(-w, 0);
    }
    if (suit.value == 2) {
      const r = w * 1.05 / 2;
      path.addOval(
          Rect.fromCircle(center: const Offset(0, -w * 0.45), radius: r));
      path.addOval(
          Rect.fromCircle(center: const Offset(-w * 0.5, w * 0.45), radius: r));
      path.addOval(
          Rect.fromCircle(center: const Offset(w * 0.5, w * 0.45), radius: r));
      path.addOval(Rect.fromCircle(center: Offset.zero, radius: w * 0.3));
    }
    if (suit.value == 3) {
      path.moveTo(0, -w);
      path.cubicTo(1.7 * w, 0.3 * w, 0.8 * w, w, 0.5 * w, w);
      path.cubicTo(0.2 * w, 0.65 * w, -0.2 * w, 0.65 * w, -0.5 * w, w);
      path.cubicTo(-0.8 * w, w, -1.7 * w, 0.3 * w, 0, -w);
      path.close();
    }
    return path.shift(
      const Offset(KlondikeGame.cardWidth * 0.5, KlondikeGame.cardHeight * 0.5),
    );
  }

   */
}
