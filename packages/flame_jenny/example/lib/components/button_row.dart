import 'package:flame/components.dart';
import 'package:jenny/jenny.dart';
import 'package:jenny_example/components/dialogue_button.dart';

class ButtonRow extends PositionComponent {
  ButtonRow({required super.size}) : super(position: Vector2(0, 96));

  void removeButtons() {
    List<DialogueButton> buttonList = children.query<DialogueButton>();
    if (buttonList.isNotEmpty) {
      for (DialogueButton dialogueButton in buttonList) {
        if (dialogueButton.parent != null) {
          dialogueButton.removeFromParent();
        }
      }
    }
  }

  void showNextButton(Function onNextButtonPressed) {
    removeButtons();
    final nextButton = DialogueButton(
      assetPath: 'green_button.png',
      text: 'Next',
      position: Vector2(size.x / 2, 0),
      onPressed: () {
        onNextButtonPressed();
        removeButtons();
      },
    );
    add(nextButton);
  }

  void showOptionButtons({
    required Function onChoice,
    required DialogueOption option1,
    required DialogueOption option2,
  }) {
    removeButtons();
    List<DialogueButton> optionButtons = [
      DialogueButton(
        assetPath: 'green_button.png',
        text: option1.text,
        position: Vector2(size.x / 4, 0),
        onPressed: () {
          onChoice(0);
          removeButtons();
        },
      ),
      DialogueButton(
        assetPath: 'red_button.png',
        text: option2.text,
        position: Vector2(size.x * 3 / 4, 0),
        onPressed: () {
          onChoice(1);
          removeButtons();
        },
      ),
    ];
    addAll(optionButtons);
  }

  void showCloseButton(Function onClose) {
    DialogueButton closeButton = DialogueButton(
      assetPath: 'green_button.png',
      text: 'Close',
      onPressed: () => onClose(),
      position: Vector2(size.x / 2, 0),
    );
    add(closeButton);
  }
}
