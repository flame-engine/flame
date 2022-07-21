import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:doc_flame_examples/decorator_blur.dart';
import 'package:doc_flame_examples/decorator_grayscale.dart';
import 'package:doc_flame_examples/decorator_shadow.dart';
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
  final routes = <String, Game Function()>{
    'tap_events': TapEventsGame.new,
    'drag_events': DragEventsGame.new,
    'decorator_blur': DecoratorBlurGame.new,
    'decorator_grayscale': DecoratorGrayscaleGame.new,
    'decorator_tint': DecoratorTintGame.new,
    'decorator_shadow3d': DecoratorShadowGame.new,
  };
  final game = (routes[page] ?? routes['decorator_shadow3d'])?.call();
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
