import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:jenny_example/commons/commons.dart';

class DialogueTextBox extends TextBoxComponent {
  DialogueTextBox({required String text})
      : super(
          text: text,
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
