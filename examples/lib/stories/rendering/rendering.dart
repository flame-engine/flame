import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'flip.dart';
import 'layers.dart';
import 'text.dart';

void addRenderingStories(Dashbook dashbook) {
  dashbook.storiesOf('Rendering')
    ..add(
      'Text',
      (_) => GameWidget(game: TextGame()),
      codeLink: baseLink('rendering/text.dart'),
    )
    ..add(
      'Flip Sprite',
      (_) => GameWidget(game: FlipSpriteGame()),
      codeLink: baseLink('rendering/flip.dart'),
    )
    ..add(
      'Layers',
      (_) => GameWidget(game: LayerGame()),
      codeLink: baseLink('rendering/layers.dart'),
    );
}
