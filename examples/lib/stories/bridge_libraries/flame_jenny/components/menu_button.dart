import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class MenuButton extends ButtonComponent {
  MenuButton({
    required super.position,
    required super.onPressed,
    required String text,
  }) : super() {
    _text = text;
  }

  late String _text;

  final Paint white = BasicPalette.white.paint();
  final TextPaint topTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );
  final startButtonSize = Vector2(128, 56);

  @override
  Future<void> onLoad() async {
    size = startButtonSize;
    button = RectangleComponent(paint: white, size: startButtonSize);
    anchor = Anchor.center;
    add(
      TextComponent(
        text: _text,
        textRenderer: topTextPaint,
        position: startButtonSize / 2,
        anchor: Anchor.center,
        priority: 1,
      ),
    );
  }
}
