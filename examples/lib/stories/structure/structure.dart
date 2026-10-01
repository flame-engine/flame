import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/structure/levels.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent structureStories() {
  return WidgetbookComponent(
    name: 'Structure',
    useCases: [
      ExampleUseCase(
        name: 'Levels',
        builder: (_) => GameWidget(game: LevelsExample()),
        info: LevelsExample.description,
        codeLink: baseLink('structure/levels.dart'),
      ),
    ],
  );
}
