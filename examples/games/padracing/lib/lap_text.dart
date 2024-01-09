import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:google_fonts/google_fonts.dart';

import 'package:padracing/car.dart';
import 'package:padracing/padracing_game.dart';

class LapText extends PositionComponent with HasGameReference<PadRacingGame> {
  LapText({required this.car, required Vector2 position})
      : super(position: position);

  final Car car;
  late final ValueNotifier<int> lapNotifier = car.lapNotifier;
  late final TextComponent _timePassedComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final textStyle = GoogleFonts.vt323(
      fontSize: 35,
      color: car.paint.color,
    );
    final defaultRenderer = TextPaint(style: textStyle);
    final lapCountRenderer = TextPaint(
      style: textStyle.copyWith(fontSize: 55, fontWeight: FontWeight.bold),
    );
    add(
      TextComponent(
        text: 'Lap',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: defaultRenderer,
      ),
    );
    final lapCounter = TextComponent(
      position: Vector2(0, 10),
      anchor: Anchor.center,
      textRenderer: lapCountRenderer,
    );
    add(lapCounter);
    void updateLapText() {
      if (lapNotifier.value <= PadRacingGame.numberOfLaps) {
        final prefix = lapNotifier.value < 10 ? '0' : '';
        lapCounter.text = '$prefix${lapNotifier.value}';
      } else {
        lapCounter.text = 'DONE';
      }
    }

    _timePassedComponent = TextComponent(
      position: Vector2(0, 70),
      anchor: Anchor.center,
      textRenderer: defaultRenderer,
    );
    add(_timePassedComponent);

    _backgroundPaint = Paint()
      ..color = car.paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    lapNotifier.addListener(updateLapText);
    updateLapText();
  }

  @override
  void update(double dt) {
    if (game.isGameOver) {
      return;
    }
    _timePassedComponent.text = game.timePassed;
  }

  final _backgroundRect = RRect.fromRectAndRadius(
    Rect.fromCircle(center: Offset.zero, radius: 50),
    const Radius.circular(10),
  );
  late final Paint _backgroundPaint;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundRect, _backgroundPaint);
  }
}
