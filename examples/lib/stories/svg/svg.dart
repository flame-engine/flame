import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/svg/collidable_svg_paths_example.dart';
import 'package:examples/stories/svg/svg_component.dart';
import 'package:examples/stories/svg/svg_paths_animation_example.dart';
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
      ExampleUseCase(
        name: 'Collidable Svg Paths',
        builder: (_) => GameWidget(game: CollidableSvgPathsExample()),
        codeLink: baseLink('svg/collidable_svg_paths_example.dart'),
        info: CollidableSvgPathsExample.description,
      ),
      ExampleUseCase(
        name: 'Svg Paths Animation',
        builder: (_) => GameWidget(game: SvgPathsAnimationExample()),
        codeLink: baseLink('svg/svg_paths_animation_example.dart'),
        info: SvgPathsAnimationExample.description,
      ),
    ],
  );
}
