import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/timer.dart';
import 'package:flame/gestures.dart';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      '/': (BuildContext context) => Column(children: [
            ElevatedButton(
              child: const Text('Game'),
              onPressed: () {
                Navigator.of(context).pushNamed('/game');
              },
            ),
            ElevatedButton(
              child: const Text('BaseGame'),
              onPressed: () {
                Navigator.of(context).pushNamed('/base_game');
              },
            ),
          ]),
      '/game': (BuildContext context) => GameWidget(game: MyGame()),
      '/base_game': (BuildContext context) => GameWidget(game: MyBaseGame()),
    });
  }
}

class RenderedTimeComponent extends TimerComponent {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));

  RenderedTimeComponent(Timer timer) : super(timer);

  @override
  void render(Canvas canvas) {
    textConfig.render(
      canvas,
      'Elapsed time: ${timer.current}',
      Vector2(10, 150),
    );
  }
}

class MyBaseGame extends BaseGame with TapDetector, DoubleTapDetector {
  @override
  void onTapDown(_) {
    add(RenderedTimeComponent(Timer(1)..start()));
  }

  @override
  void onDoubleTap() {
    add(RenderedTimeComponent(Timer(5)..start()));
  }
}

class MyGame extends Game with TapDetector {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  Timer? countdown;
  Timer? interval;

  int elapsedSecs = 0;

  MyGame() {
    countdown = Timer(2);
    interval = Timer(
      1,
      callback: () => elapsedSecs += 1,
      repeat: true,
    );
    interval!.start();
  }

  @override
  void onTapDown(_) {
    countdown!.start();
  }

  @override
  void update(double dt) {
    countdown!.update(dt);
    interval!.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(
      canvas,
      'Countdown: ${countdown!.current}',
      Vector2(10, 100),
    );
    textConfig.render(canvas, 'Elapsed time: $elapsedSecs', Vector2(10, 150));
  }
}
