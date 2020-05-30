import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/animation.dart' as animation;
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/position.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flame/widgets/sprite_widget.dart';
import 'package:flutter/material.dart';

Sprite _sprite;
animation.Animation _animation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _sprite = await Sprite.loadSprite('minotaur.png', width: 96, height: 96);

  await Flame.images.load('minotaur.png');
  final _animationSpriteSheet = SpriteSheet(
    imageName: 'minotaur.png',
    columns: 19,
    rows: 1,
    textureWidth: 96,
    textureHeight: 96,
  );
  _animation = _animationSpriteSheet.createAnimation(
    0,
    stepTime: 0.2,
    to: 19,
  );

  runApp(MyApp());
}

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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _position = Position(10 + _position.x, 10 + _position.y);
    });
  }

  void _clickFab(GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(
      const SnackBar(
        content: const Text('You clicked the FAB!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text('Animation as a Widget Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Hi there! This is a regular Flutter app,'),
            const Text('with a complex widget tree and also'),
            const Text('some pretty sprite sheet animations :)'),
            Container(
              width: 200,
              height: 200,
              child: AnimationWidget(animation: _animation),
            ),
            const Text('Neat, hum?'),
            const Text(
                'By the way, you can also use static sprites as widgets:'),
            Container(
              width: 200,
              height: 200,
              child: SpriteWidget(sprite: _sprite),
            ),
            const Text('Sprites from Elthen\'s amazing work on itch.io:'),
            const Text('https://elthen.itch.io/2d-pixel-art-minotaur-sprites'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _clickFab(key),
        child: const Icon(Icons.add),
      ),
    );
  }
}
