import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/svg/svg_component.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent svgStories() {
  return WidgetbookComponent(
    name: 'Svg',
    useCases: [
      ExampleUseCase(
        name: 'Svg Component',
        builder: (_) => GameWidget(game: SvgComponentExample()),
        codeLink: baseLink('svg/svg_component.dart'),
        info: SvgComponentExample.description,
      ),
    ],
  );
}
