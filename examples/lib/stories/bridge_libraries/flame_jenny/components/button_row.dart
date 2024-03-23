import 'package:examples/stories/bridge_libraries/flame_jenny/components/dialogue_button.dart';
import 'package:flame/components.dart';
import 'package:jenny/jenny.dart';

class ButtonRow extends PositionComponent {
  ButtonRow({required super.size}) : super(position: Vector2(0, 96));

  void removeButtons() {
    final buttonList = children.query<DialogueButton>();
    if (buttonList.isNotEmpty) {
      for (final dialogueButton in buttonList) {
        if (dialogueButton.parent != null) {
          dialogueButton.removeFromParent();
        }
      }
    }
  }

  void showNextButton(Function() onNextButtonPressed) {
    removeButtons();
    final nextButton = DialogueButton(
      assetPath: 'green_button_sqr.png',
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
    required Function(int optionNumber) onChoice,
    required DialogueOption option1,
    required DialogueOption option2,
  }) {
    removeButtons();
    final optionButtons = <DialogueButton>[
      DialogueButton(
        assetPath: 'green_button_sqr.png',
        text: option1.text,
        position: Vector2(size.x / 4, 0),
        onPressed: () {
          onChoice(0);
          removeButtons();
        },
      ),
      DialogueButton(
        assetPath: 'red_button_sqr.png',
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

  void showCloseButton(Function() onClose) {
    final closeButton = DialogueButton(
      assetPath: 'green_button_sqr.png',
      text: 'Close',
      onPressed: () => onClose(),
      position: Vector2(size.x / 2, 0),
    );
    add(closeButton);
  }
}
