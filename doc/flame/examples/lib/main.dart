import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'tap_events.dart';

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
