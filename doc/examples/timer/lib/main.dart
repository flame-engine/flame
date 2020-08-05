import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/time.dart';
import 'package:flame/text_config.dart';
import 'package:flame/position.dart';
import 'package:flame/gestures.dart';
import 'package:flame/components/timer_component.dart';

void main() {
  runApp(GameWidget());
}

class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      '/': (BuildContext context) => Column(children: [
            RaisedButton(
                child: const Text("Game"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/game");
                }),
            RaisedButton(
                child: const Text("BaseGame"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/base_game");
                })
          ]),
      '/game': (BuildContext context) => MyGame().widget,
      '/base_game': (BuildContext context) => MyBaseGame().widget
    });
  }
}

class RenderedTimeComponent extends TimerComponent {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));

  RenderedTimeComponent(Timer timer) : super(timer);

  @override
  void render(Canvas canvas) {
    textConfig.render(
        canvas, "Elapsed time: ${timer.current}", Position(10, 150));
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
  Timer countdown;
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    countdown = Timer(2);
    interval = Timer(1, repeat: true, callback: () {
      elapsedSecs += 1;
    });
    interval.start();
  }

  @override
  void onTapDown(_) {
    countdown.start();
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(canvas, "Countdown: ${countdown.current.toString()}",
        Position(10, 100));
    textConfig.render(canvas, "Elapsed time: $elapsedSecs", Position(10, 150));
  }
}
