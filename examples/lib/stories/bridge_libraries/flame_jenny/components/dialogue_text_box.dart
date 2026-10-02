import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';

class DialogueTextBox({required super.text}) extends TextBoxComponent {
  this
    : super(
        position: Vector2(16, 16),
        size: Vector2(704, 96),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: fontSize,
            color: Colors.black,
          ),
        ),
      );
}
