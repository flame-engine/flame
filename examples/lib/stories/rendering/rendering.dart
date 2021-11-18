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
      (_) => GameWidget(game: TextExample()),
      codeLink: baseLink('rendering/text.dart'),
      info: TextExample.description,
    )
    ..add(
      'Flip Sprite',
      (_) => GameWidget(game: FlipSpriteExample()),
      codeLink: baseLink('rendering/flip.dart'),
      info: FlipSpriteExample.description,
    )
    ..add(
      'Layers',
      (_) => GameWidget(game: LayerExample()),
      codeLink: baseLink('rendering/layers.dart'),
      info: LayerExample.description,
    );
}
