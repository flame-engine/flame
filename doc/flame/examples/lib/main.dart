import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:doc_flame_examples/decorator_blur.dart';
import 'package:doc_flame_examples/decorator_grayscale.dart';
import 'package:doc_flame_examples/decorator_rotate3d.dart';
import 'package:doc_flame_examples/decorator_tint.dart';
import 'package:doc_flame_examples/drag_events.dart';
import 'package:doc_flame_examples/tap_events.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  Game? game;
  switch (page) {
    case 'tap_events':
      game = TapEventsGame();
      break;
    case 'drag_events':
      game = DragEventsGame();
      break;
    case 'decorator_blur':
      game = DecoratorBlurGame();
      break;
    case 'decorator_grayscale':
      game = DecoratorGrayscaleGame();
      break;
    case 'decorator_rotate3d':
      game = DecoratorRotate3DGame();
      break;
    case 'decorator_tint':
      game = DecoratorTintGame();
      break;
  }
  if (game != null) {
    runApp(GameWidget(game: game));
  } else {
    runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Error: unknown page name "$page"'),
      ),
    );
  }
}
