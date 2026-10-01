import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/utils/timer_component_example.dart';
import 'package:examples/stories/utils/timer_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent utilsStories() {
  return WidgetbookComponent(
    name: 'Utils',
    useCases: [
      ExampleUseCase(
        name: 'Timer',
        builder: (_) => GameWidget(game: TimerExample()),
        codeLink: baseLink('utils/timer_example.dart'),
        info: TimerExample.description,
      ),
      ExampleUseCase(
        name: 'Timer Component',
        builder: (_) => GameWidget(game: TimerComponentExample()),
        codeLink: baseLink('utils/timer_component_example.dart'),
        info: TimerComponentExample.description,
      ),
    ],
  );
}
