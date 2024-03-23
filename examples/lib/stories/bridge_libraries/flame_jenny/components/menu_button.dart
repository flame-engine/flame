import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class MenuButton extends ButtonComponent {
  MenuButton({
    required super.position,
    required super.onPressed,
    required this.text,
  }) : super(size: Vector2(128, 42));

  late String text;

  final Paint white = BasicPalette.white.paint();
  final TextPaint topTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );

  @override
  Future<void> onLoad() async {
    button = RectangleComponent(paint: white, size: size);
    anchor = Anchor.center;
    add(
      TextComponent(
        text: text,
        textRenderer: topTextPaint,
        position: size / 2,
        anchor: Anchor.center,
        priority: 1,
      ),
    );
  }
}
