import 'dart:ui';

import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_controller_component.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/components/menu_button.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/services.dart';
import 'package:jenny/jenny.dart';

class JennyAdvancedExample extends FlameGame {
  static const String description = '''
    This is an advanced example of how to use the Jenny Package. 
    It includes implementing dialogue choices, setting custom variables,
    using commands and implementing User-Defined Commands, .
  ''';

  int coins = 0;

  final Paint white = BasicPalette.white.paint();
  final TextPaint mainTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.white.color),
  );
  final TextPaint buttonTextPaint = TextPaint(
    style: TextStyle(color: BasicPalette.black.color),
  );
  final startButtonSize = Vector2(128, 56);

  late final TextComponent header = TextComponent(
    text: 'Select player name.',
    position: Vector2(size.x / 2, 56),
    size: startButtonSize,
    anchor: Anchor.center,
    textRenderer: mainTextPaint,
  );

  Future<void> startDialogue(String playerName) async {
    final dialogueControllerComponent = DialogueControllerComponent();
    add(dialogueControllerComponent);

    final yarnProject = YarnProject();

    yarnProject
      ..commands.addCommand1('updateCoins', updateCoins)
      ..variables.setVariable(r'$playerName', playerName)
      ..parse(await rootBundle.loadString('assets/yarn/advanced.yarn'));
    final dialogueRunner = DialogueRunner(
      yarnProject: yarnProject,
      dialogueViews: [dialogueControllerComponent],
    );
    dialogueRunner.startDialogue('gamble');
  }

  void updateCoins(int amountChange) {
    coins += amountChange;
    header.text = 'Select player name. Current coins: $coins';
  }

  @override
  Future<void> onLoad() async {
    addAll([
      header,
      MenuButton(
        position: Vector2(size.x / 4, 128),
        onPressed: () => startDialogue('Jessie'),
        text: 'Jessie',
      ),
      MenuButton(
        position: Vector2(size.x * 3 / 4, 128),
        onPressed: () => startDialogue('James'),
        text: 'James',
      ),
    ]);
  }
}
