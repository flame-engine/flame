import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComponentsNotifierExampleWidget extends StatefulWidget {
  const ComponentsNotifierExampleWidget({super.key});

  static String description = '''
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
      body: MultiProvider(
        providers: [
          Provider<ComponentNotifierExample>.value(value: game),
          ChangeNotifierProvider<ComponentsNotifier<Enemy>>(
            create: (_) => game.componentsNotifier<Enemy>(),
          ),
        ],
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget(game: game),
            ),
            const Positioned(
              left: 16,
              top: 16,
              child: GameHud(),
            ),
          ],
        ),
      ),
    );
  }
}

class GameHud extends StatelessWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    final enemies = context.watch<ComponentsNotifier<Enemy>>().components;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: enemies.isEmpty
            ? ElevatedButton(
                child: const Text('Play again'),
                onPressed: () {
                  context.read<ComponentNotifierExample>().replay();
                },
              )
            : Text('Remaining enemies: ${enemies.length}'),
      ),
    );
  }
}

class Enemy extends CircleComponent with Tappable, Notifiable {
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
