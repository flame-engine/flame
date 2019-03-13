import 'dart:async';

import 'package:flame/animation.dart' as animation;
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation as a Widget Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Position _position = Position(256.0, 256.0);

  @override
  void initState() {
    super.initState();
    changePosition();
  }

  void changePosition() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _position = Position(10 + _position.x, 10 + _position.y);
    });
  }

  void _clickFab(GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(
      content: Text('You clicked the FAB!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('Animation as a Widget Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Hi there! This is a regular Flutter app,'),
            Text('with a complex widget tree and also'),
            Text('some pretty sprite sheet animations :)'),
            Flame.util.animationAsWidget(
                _position,
                animation.Animation.sequenced('minotaur.png', 19,
                    textureWidth: 96.0)),
            Text('Neat, hum?'),
            Text('Sprites from Elthen\'s amazing work on itch.io:'),
            Text('https://elthen.itch.io/2d-pixel-art-minotaur-sprites'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _clickFab(key),
        child: Icon(Icons.add),
      ),
    );
  }
}
