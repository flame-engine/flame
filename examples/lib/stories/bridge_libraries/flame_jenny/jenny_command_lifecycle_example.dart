import 'package:examples/stories/bridge_libraries/flame_jenny/components/command_lifecycle_dialogue_controller.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/components/menu_button.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:jenny/jenny.dart';

class JennyCommandLifecycleExample extends FlameGame {
  static const String description = '''
This is an example of how the lifecycle methods relating to user-defined
commands work.
  ''';

  final TextComponent onCommandLabel = TextComponent(text: '');
  final TextComponent onCommandFinishLabel = TextComponent(text: '');

  static const initialOnCommandLabelText = 'onCommand: ???';
  static const initialOnCommandFinishLabelText = 'onCommandFinish: ???';

  Future<void> startDialogue() async {
    // Initialize the labels
    onCommandLabel.text = initialOnCommandLabelText;
    onCommandFinishLabel.text = initialOnCommandFinishLabelText;
    final yarnProject = YarnProject();
    final dialogueControllerComponent = CommandLifecycleDialogueController(
      onCommandOverride: (command) async {
        final exampleVariable = yarnProject.variables.getVariable(
          r'$exampleVariable',
        );
        onCommandLabel.text = 'onCommand: $exampleVariable';
      },
      onCommandFinishOverride: (command) async {
        final exampleVariable = yarnProject.variables.getVariable(
          r'$exampleVariable',
        );
        onCommandFinishLabel.text = 'onCommandFinish: $exampleVariable';
      },
    );
    add(dialogueControllerComponent);
    add(
      ColumnComponent(
        children: [
          onCommandLabel,
          onCommandFinishLabel,
        ],
      ),
    );
    yarnProject.commands.addCommand1('exampleCommand', (String someData) async {
      /// Placeholder for some asynchronous event, like... maybe a dice roll.
      await Future.delayed(const Duration(milliseconds: 300));
      yarnProject.variables.setVariable(r'$exampleVariable', someData);
    });
    yarnProject.parse(
      await rootBundle.loadString('assets/yarn/command_lifecycle.yarn'),
    );
    final dialogueRunner = DialogueRunner(
      yarnProject: yarnProject,
      dialogueViews: [dialogueControllerComponent],
    );
    dialogueRunner.startDialogue('command_lifecycle');
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
