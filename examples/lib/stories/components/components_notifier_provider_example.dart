import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const ComponentsNotifierProviderExampleWidget({super.key})
    extends StatefulWidget {
  static const String description = '''
      Similar to the Components Notifier example, but uses provider
      instead of the built in ComponentsNotifierBuilder widget.
''';

  @override
  State<ComponentsNotifierProviderExampleWidget> createState() =>
      _ComponentsNotifierProviderExampleWidgetState();
}

class _ComponentsNotifierProviderExampleWidgetState()
    extends State<ComponentsNotifierProviderExampleWidget> {
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

class const GameHud({super.key}) extends StatelessWidget {
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

class Enemy({super.position})
    extends CircleComponent
    with TapCallbacks, Notifier {
  this
    : super(
        radius: 20,
        paint: Paint()..color = const Color(0xFFFF0000),
      );

  @override
  void onTapUp(_) {
    removeFromParent();
  }
}

class ComponentNotifierExample() extends FlameGame {
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
