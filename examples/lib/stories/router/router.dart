import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/router/router_world_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent routerStories() {
  return WidgetbookComponent(
    name: 'Router',
    useCases: [
      ExampleUseCase(
        name: 'Router with multiple worlds',
        builder: (_) => GameWidget(game: RouterWorldExample()),
        codeLink: baseLink('router/router_world_example.dart'),
        info: RouterWorldExample.description,
      ),
    ],
  );
}
