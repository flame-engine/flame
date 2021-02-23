import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import './example_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ExampleGame _myGame;

  Widget pauseMenuBuilder(BuildContext buildContext, ExampleGame game) {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        color: const Color(0xFFFF0000),
        child: const Center(
          child: Text('Paused'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing addingOverlay'),
      ),
      body: _myGame == null
          ? const Text('Wait')
          : GameWidget<ExampleGame>(
              game: _myGame,
              overlayBuilderMap: {
                'PauseMenu': pauseMenuBuilder,
              },
              initialActiveOverlays: const ['PauseMenu'],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: newGame,
        child: const Icon(Icons.add),
      ),
    );
  }

  void newGame() {
    setState(() {
      _myGame = ExampleGame();
      print('New game created');
    });
  }
}
