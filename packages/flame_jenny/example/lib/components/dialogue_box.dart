import 'package:flame/components.dart';
import 'package:jenny/jenny.dart';
import 'package:jenny_example/components/button_row.dart';
import 'package:jenny_example/components/dialogue_text_box.dart';

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

  void removeTextBox() {
    textBox.removeFromParent();
  }

  void changeText(String newText, Function goNextLine) {
    removeTextBox();
    textBox = DialogueTextBox(text: newText);
    add(textBox);
    buttonRow.showNextButton(goNextLine);
  }

  void showOptions({
    required Function onChoice,
    required DialogueOption option1,
    required DialogueOption option2,
  }) {
    buttonRow.showOptionButtons(
      onChoice: onChoice,
      option1: option1,
      option2: option2,
    );
  }

  void showCloseButton(Function onClose) {
    void closeDialogue() {
      removeTextBox();
      onClose();
    }

    buttonRow.showCloseButton(closeDialogue);
  }
}
