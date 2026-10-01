import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/layout/align_component.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent layoutStories() {
  return WidgetbookComponent(
    name: 'Layout',
    useCases: [
      ExampleUseCase(
        name: 'AlignComponent',
        builder: (_) => GameWidget(game: AlignComponentExample()),
        codeLink: baseLink('layout/align_component.dart'),
        info: AlignComponentExample.description,
      ),
    ],
  );
}
