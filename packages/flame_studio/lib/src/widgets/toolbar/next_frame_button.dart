import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/widgets/toolbar/toolbar_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NextFrameButton extends ConsumerWidget {
  const NextFrameButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);

    return ToolbarButton(
      icon: Path()
        ..moveTo(-4, 5)
        ..lineTo(-4, -5)
        ..lineTo(1, 0)
        ..close()
        ..addRect(const Rect.fromLTWH(1, -4.5, 3, 9)),
      disabled: !gameState.paused,
      onClick: () {
        ref.read(gameControllerProvider.notifier).stepGame();
      },
    );
  }
}
