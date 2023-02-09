import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PauseButton extends ConsumerWidget {
  const PauseButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);

    return ToolbarButton(
      icon: Path()
        ..addRect(const Rect.fromLTRB(-4, -4.5, -1, 4.5))
        ..addRect(const Rect.fromLTRB(1, -4.5, 4, 4.5)),
      disabled: gameState.paused,
      onClick: () {
        ref.read(gameControllerProvider.notifier).pauseGame();
      },
    );
  }
}
