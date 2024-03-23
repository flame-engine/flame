import 'package:examples/stories/bridge_libraries/flame_jenny/components/button_row.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_text_box.dart';
import 'package:flame/components.dart';
import 'package:jenny/jenny.dart';

class DialogueBoxComponent extends SpriteComponent with HasGameReference {
  DialogueTextBox textBox = DialogueTextBox(text: '');
  final Vector2 spriteSize = Vector2(736, 128);
  late final ButtonRow buttonRow = ButtonRow(size: spriteSize);

  @override
  Future<void> onLoad() async {
    position = Vector2(game.size.x / 2, 96);
    anchor = Anchor.center;
    sprite = await Sprite.load(
      'dialogue_box.png',
      srcSize: spriteSize,
    );
    await addAll([buttonRow, textBox]);
    return super.onLoad();
  }

  void changeText(String newText, Function() goNextLine) {
    textBox.text = newText;
    buttonRow.showNextButton(goNextLine);
  }

  void showOptions({
    required Function(int optionNumber) onChoice,
    required DialogueOption option1,
    required DialogueOption option2,
  }) {
    buttonRow.showOptionButtons(
      onChoice: onChoice,
      option1: option1,
      option2: option2,
    );
  }

  void showCloseButton(Function() onClose) {
    buttonRow.showCloseButton(onClose);
  }
}
