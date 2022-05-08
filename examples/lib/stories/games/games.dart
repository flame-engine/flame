import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../commons/commons.dart';
import 'trex/trex_game.dart';

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
