import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:material_ui/material_ui.dart';

class DialogueButton({
  required super.position,
  required final String assetPath,
  required final String text,
  required super.onPressed,
  super.anchor = Anchor.center,
}) extends SpriteButtonComponent {
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
