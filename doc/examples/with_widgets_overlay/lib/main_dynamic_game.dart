import 'package:flutter/material.dart';

import './example_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ExampleGame _myGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Testing addingOverlay'),
        ),
        body: _myGame == null ? const Text('Wait') : _myGame.widget,
        floatingActionButton: FloatingActionButton(
          onPressed: () => newGame(),
          child: const Icon(Icons.add),
        ));
  }

  void newGame() {
    print('New game created');
    _myGame = ExampleGame();
    setState(() {});
  }
}
