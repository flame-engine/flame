import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

class ComponentsNotifierExampleWidget extends StatefulWidget {
  const ComponentsNotifierExampleWidget({super.key});

  static String description = '''
      Showcases how the components notifier can be used between
      a flame game instance and widgets.

      Tap the red dots to defeat the enemies and see the hud being updated
      to reflect the current state of the game.
''';

  @override
  State<ComponentsNotifierExampleWidget> createState() =>
      _ComponentsNotifierExampleWidgetState();
}

class _ComponentsNotifierExampleWidgetState
    extends State<ComponentsNotifierExampleWidget> {
  @override
  void initState() {
    super.initState();

    game = ComponentNotifierExample();
  }

  late final ComponentNotifierExample game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(game: game),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: ComponentsNotifierBuilder<Enemy>(
              notifier: game.componentsNotifier<Enemy>(),
              builder: (context, notifier) {
                return GameHud(
                  remainingEnemies: notifier.components.length,
                  onReplay: game.replay,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.remainingEnemies,
    required this.onReplay,
  });

  final int remainingEnemies;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: remainingEnemies == 0
            ? ElevatedButton(
                onPressed: onReplay,
                child: const Text('Play again'),
              )
            : Text('Remaining enemies: $remainingEnemies'),
      ),
    );
  }
}

class Enemy extends CircleComponent with Tappable, Notifier {
  Enemy({super.position})
      : super(
          radius: 20,
          paint: Paint()..color = const Color(0xFFFF0000),
        );

  @override
  bool onTapUp(_) {
    removeFromParent();
    return true;
  }
}

class ComponentNotifierExample extends FlameGame with HasTappables {
  @override
  Future<void> onLoad() async {
    replay();
  }

  void replay() {
    add(Enemy(position: Vector2(100, 100)));
    add(Enemy(position: Vector2(200, 100)));
    add(Enemy(position: Vector2(300, 100)));
  }
}
