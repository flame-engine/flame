import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartButton extends ConsumerWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);

    return ToolbarButton(
      icon: Path()
        ..moveTo(-2.5, 5)
        ..lineTo(-2.5, -5)
        ..lineTo(6, 0)
        ..close(),
      disabled: !gameState.paused,
      onClick: () {
        ref.read(gameControllerProvider.notifier).resumeGame();
      },
    );
  }
}
