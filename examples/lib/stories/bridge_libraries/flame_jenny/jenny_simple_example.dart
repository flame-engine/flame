import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/components/menu_button.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:jenny/jenny.dart';

class JennySimpleExample extends FlameGame {
  static const String description = '''
    This example shows how to use the Jenny API. .
  ''';

  final dialogueControllerComponent = DialogueControllerComponent();

  Future<void> startDialogue() async {
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
      dialogueControllerComponent,
      MenuButton(
        position: Vector2(size.x / 2, 96),
        onPressed: startDialogue,
        text: 'Start conversation',
      ),
    ]);
  }
}
