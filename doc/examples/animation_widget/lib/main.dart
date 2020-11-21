import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/sprite_animation.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/widgets/animation_widget.dart';
import 'package:flame/widgets/sprite_widget.dart';
import 'package:flutter/material.dart';

Sprite _sprite;
SpriteAnimation _animation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final image = await Flame.images.load('minotaur.png');
  _sprite = Sprite(image, srcSize: Vector2.all(96));

  final _animationSpriteSheet = SpriteSheet(
    image: image,
    srcSize: Vector2.all(96),
  );
  _animation = _animationSpriteSheet.createAnimation(
    row: 0,
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
  Vector2 _position = Vector2.all(256);

  @override
  void initState() {
    super.initState();
    changePosition();
  }

  void changePosition() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() => _position += Vector2.all(10));
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
              child: SpriteAnimationWidget(animation: _animation),
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
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('You clicked the FAB!'),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
