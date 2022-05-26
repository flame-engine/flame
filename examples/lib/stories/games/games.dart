import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/games/padracing/game.dart';
import 'package:examples/stories/games/padracing/padracing_widget.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:trex_game/trex_game.dart';

void addGameStories(Dashbook dashbook) {
  dashbook.storiesOf('Sample Games')
    ..add(
      'Padracing',
      (_) => const PadracingWidget(),
      codeLink: baseLink('games/padracing'),
      info: PadRacingGame.description,
    )
    ..add(
      'T-Rex',
      (_) => Container(
        color: Colors.black,
        margin: const EdgeInsets.all(45),
        child: ClipRect(
          child: GameWidget(
            game: TRexGame(),
            loadingBuilder: (_) => const Center(
              child: Text('Loading'),
            ),
          ),
        ),
      ),
      codeLink: baseLink('games/trex'),
      info: TRexGame.description,
    );
}
