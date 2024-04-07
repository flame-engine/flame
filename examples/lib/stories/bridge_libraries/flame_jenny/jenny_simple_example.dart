import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/components/menu_button.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:jenny/jenny.dart';

class JennySimpleExample extends FlameGame {
  static const String description = '''
    This is a simple example of how to use the Jenny Package. 
    It includes instantiating YarnProject and parsing a .yarn script.
  ''';

  Future<void> startDialogue() async {
    final dialogueControllerComponent = DialogueControllerComponent();
    add(dialogueControllerComponent);

    final yarnProject = YarnProject();
    yarnProject.parse(await rootBundle.loadString('assets/yarn/simple.yarn'));
    final dialogueRunner = DialogueRunner(
      yarnProject: yarnProject,
      dialogueViews: [dialogueControllerComponent],
    );
    dialogueRunner.startDialogue('hello_world');
  }

  @override
  Future<void> onLoad() async {
    addAll([
      MenuButton(
        position: Vector2(size.x / 2, 96),
        onPressed: startDialogue,
        text: 'Start conversation',
      ),
    ]);
  }
}
