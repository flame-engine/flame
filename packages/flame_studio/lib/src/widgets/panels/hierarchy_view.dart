import 'package:flame/game.dart';
import 'package:flame_studio/src/core/game_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HierarchyView extends ConsumerWidget {
  const HierarchyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameController = ref.watch(gameControllerProvider);
    final game = gameController.game as FlameGame?;
    if (game == null) {
      return Container();
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        for (final component in game.children)
          Container(
            child: Text(
              '${component.runtimeType}',
              style: const TextStyle(
                color: Color(0xffffffff),
              ),
            ),
          ),
      ],
    );
  }
}
