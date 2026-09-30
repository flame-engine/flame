import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/rendering/decorator_hue_example.dart';
import 'package:examples/stories/rendering/decorator_vs_effect_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent decoratorStories() {
  return WidgetbookComponent(
    name: 'Decorators',
    useCases: [
      ExampleUseCase(
        name: 'Decorator Hue',
        builder: (_) => GameWidget(game: DecoratorHueExample()),
        codeLink: baseLink('rendering/decorator_hue_example.dart'),
        info: DecoratorHueExample.description,
      ),
      ExampleUseCase(
        name: 'Decorators vs Effects',
        builder: (_) => GameWidget(game: DecoratorVsEffectExample()),
        codeLink: baseLink('rendering/decorator_vs_effect_example.dart'),
        info: DecoratorVsEffectExample.description,
      ),
    ],
  );
}
