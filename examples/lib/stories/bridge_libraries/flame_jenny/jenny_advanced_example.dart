import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/services.dart';
import 'package:jenny/jenny.dart';

class JennyAdvancedExample extends FlameGame {
  static const String description = '''
    This example shows how to use the Jenny API. .
  ''';

  final Paint white = BasicPalette.white.paint();
  final TextPaint topTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );
  final startButtonSize = Vector2(128, 56);

  late DialogueRunner dialogueRunner;

  void startDialogue() {
    dialogueRunner.startDialogue('hello_world');
  }

  @override
  Future<void> onLoad() async {
    final dialogueControllerComponent = DialogueControllerComponent();

    add(dialogueControllerComponent);
    final yarnProject = YarnProject();
    yarnProject.parse(await rootBundle.loadString('assets/yarn/simple.yarn'));
    dialogueRunner = DialogueRunner(
      yarnProject: yarnProject,
      dialogueViews: [dialogueControllerComponent],
    );

    add(
      ButtonComponent(
        position: Vector2(size.x / 2, 96),
        size: startButtonSize,
        button: RectangleComponent(paint: white, size: startButtonSize),
        onPressed: startDialogue,
        anchor: Anchor.center,
        children: [
          TextComponent(
            text: 'Start conversation',
            textRenderer: topTextPaint,
            position: startButtonSize / 2,
            anchor: Anchor.center,
            priority: 1,
          ),
        ],
      ),
    );
  }
}