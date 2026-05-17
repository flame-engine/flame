import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/rendering/decorator_hue_example.dart';
import 'package:examples/stories/rendering/decorator_vs_effect_example.dart';
import 'package:flame/game.dart';

void addDecoratorStories(Dashbook dashbook) {
  dashbook.storiesOf('Decorators')
    ..add(
      'Decorator Hue',
      (_) => GameWidget(game: DecoratorHueExample()),
      codeLink: baseLink('rendering/decorator_hue_example.dart'),
      info: DecoratorHueExample.description,
    )
    ..add(
      'Decorators vs Effects',
      (_) => GameWidget(game: DecoratorVsEffectExample()),
      codeLink: baseLink('rendering/decorator_vs_effect_example.dart'),
      info: DecoratorVsEffectExample.description,
    );
}
