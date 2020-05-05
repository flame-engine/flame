import 'package:flutter/material.dart' hide Image;

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';

import 'dart:ui';

void main() async {
  const exampleUrl =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAxElEQVQ4jYWTMQ7DIAxFIeoNuAGK1K1ISL0DMwOHzNC5p6iUPeoNOEM7GZnPJ/EUbP7Lx7KtIfH91B/L++gs5m5M9NreTN/dEZiVghatwbXvY68UlksyPjprRaxFGAJZg+uAuSSzzC7rEDirDYAz2wg0RjWRFa/EUwdnQnQ37QFe1Odjrw04AKTTaBXPAlx8dDaXdNk4rMsc0B7ge/UcYLTZxoFizxCQ/L0DMAhaX4Mzj/uzW6phu3AvtHUUU4BAWJ6t8x9N/HHcruXjwQAAAABJRU5ErkJggg==';

  final image = await Flame.images.fromBase64('shield.png', exampleUrl);

  runApp(MyGame(image).widget);
}

class MyGame extends Game {
  Sprite _sprite;

  MyGame(Image image) {
    _sprite = Sprite.fromImage(image);
  }

  @override
  void update(dt) {}

  @override
  void render(Canvas canvas) {
    _sprite.renderRect(canvas, const Rect.fromLTWH(100, 100, 100, 100));
  }
}
