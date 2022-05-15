import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/games/trex/trex_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void addGameStories(Dashbook dashbook) {
  dashbook.storiesOf('Sample Games').add(
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
