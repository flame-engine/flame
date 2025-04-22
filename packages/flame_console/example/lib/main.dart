import 'package:flame/game.dart';
import 'package:flame_console/flame_console.dart';
import 'package:flame_console_example/commands/commands.dart';
import 'package:flame_console_example/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MyGameApp()));
}

class MyGameApp extends StatefulWidget {
  const MyGameApp({super.key});

  @override
  State<MyGameApp> createState() => _MyGameAppState();
}

class _MyGameAppState extends State<MyGameApp> {
  late final MyGame _game;

  @override
  void initState() {
    super.initState();

    _game = MyGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        overlayBuilderMap: {
          'console': (BuildContext context, MyGame game) => FlameConsoleView(
                game: game,
                customCommands:
                    customCommandsProvider.map((it) => it()).toList(),
                onClose: () {
                  _game.overlays.remove('console');
                },
              ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'console_button',
        onPressed: () {
          _game.overlays.add('console');
        },
        child: const Icon(Icons.developer_mode),
      ),
    );
  }
}
