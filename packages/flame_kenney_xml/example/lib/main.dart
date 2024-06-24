import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:flutter/material.dart';

/// A simple game that adds a random sprite component created from a kenney.nl
/// sprite sheet to the screen when tapped.
void main() {
  runApp(
    GameWidget.controlled(
      gameFactory: () => FlameGame(world: KenneyWorld()),
    ),
  );
}

class KenneyWorld extends World with TapCallbacks {
  late final XmlSpriteSheet spritesheet;

  @override
  Future<void> onLoad() async {
    spritesheet = await XmlSpriteSheet.load(
      imagePath: 'spritesheet_stone.png',
      xmlPath: 'spritesheet_stone.xml',
    );
    add(randomSpriteComponent());
  }

  @override
  void onTapDown(TapDownEvent event) {
    add(randomSpriteComponent(position: event.localPosition));
  }

  SpriteComponent randomSpriteComponent({Vector2? position}) {
    final name = spritesheet.spriteNames.random();
    return SpriteComponent(
      sprite: spritesheet.getSprite(name),
      position: position,
      anchor: Anchor.center,
    );
  }
}
