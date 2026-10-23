import 'package:flame/components.dart' show Component, Vector2;
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flame_studio/src/core/selection.dart';
import 'package:flame_studio/src/core/viewport_tool.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Covers the game while the select tool is in use, selecting the component
/// under the pointer on taps, and keeping the pointer events from the game.
///
/// When another tool is in use this layer is empty, so that the pointer events
/// reach the game.
class const SelectToolLayer({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(viewportToolProvider);
    if (tool != ViewportTool.select) {
      return const SizedBox.shrink();
    }
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _select(ref, details.globalPosition),
      ),
    );
  }

  void _select(WidgetRef ref, Offset globalPosition) {
    final game = ref.read(gameControllerProvider).game;
    if (game == null || !game.isAttached || game is! Component) {
      return;
    }
    final point = game.renderBox.globalToLocal(globalPosition);
    final candidates = pickableComponentsAt(
      game as Component,
      Vector2(point.dx, point.dy),
    );
    final selection = ref.read(selectedComponentProvider.notifier);
    selection.select(pickNext(candidates, ref.read(selectedComponentProvider)));
  }
}
