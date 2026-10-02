import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:material_ui/material_ui.dart';

class MenuButton({
  required super.position,
  required super.onPressed,
  required var String text,
}) extends ButtonComponent {
  this : super(size: Vector2(128, 42));

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
