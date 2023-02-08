import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';

class PauseButton extends StatelessWidget {
  const PauseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameController.of(context);
    return ToolbarButton(
      icon: Path()
        ..addRect(const Rect.fromLTRB(-4, -4.5, -1, 4.5))
        ..addRect(const Rect.fromLTRB(1, -4.5, 4, 4.5)),
      disabled: controller.isPaused,
      onClick: controller.pauseGame,
    );
  }
}
