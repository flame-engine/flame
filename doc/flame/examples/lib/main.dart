import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:doc_flame_examples/decorator_blur.dart';
import 'package:doc_flame_examples/decorator_grayscale.dart';
import 'package:doc_flame_examples/decorator_rotate3d.dart';
import 'package:doc_flame_examples/decorator_shadow3d.dart';
import 'package:doc_flame_examples/decorator_tint.dart';
import 'package:doc_flame_examples/drag_events.dart';
import 'package:doc_flame_examples/router.dart';
import 'package:doc_flame_examples/tap_events.dart';
import 'package:doc_flame_examples/value_route.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  final routes = <String, Game Function()>{
    'decorator_blur': DecoratorBlurGame.new,
    'decorator_grayscale': DecoratorGrayscaleGame.new,
    'decorator_rotate3d': DecoratorRotate3DGame.new,
    'decorator_shadow3d': DecoratorShadowGame.new,
    'decorator_tint': DecoratorTintGame.new,
    'drag_events': DragEventsGame.new,
    'router': RouterGame.new,
    'tap_events': TapEventsGame.new,
    'value_route': ValueRouteExample.new,
  };
  final game = routes[page]?.call();
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
