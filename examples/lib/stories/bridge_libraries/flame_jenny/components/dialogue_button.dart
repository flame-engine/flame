import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class DialogueButton extends SpriteButtonComponent {
  DialogueButton({
    required super.position,
    required this.assetPath,
    required this.text,
    required super.onPressed,
    super.anchor = Anchor.center,
  });

  final String text;
  final String assetPath;

  @override
  Future<void> onLoad() async {
    button = await Sprite.load(assetPath);
    add(
      TextComponent(
        text: text,
        position: Vector2(48, 16),
        anchor: Anchor.center,
        size: Vector2(88, 28),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: fontSize,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
