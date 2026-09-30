import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_isolate/simple_isolate_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent flameIsolateStories() {
  return WidgetbookComponent(
    name: 'FlameIsolate',
    useCases: [
      ExampleUseCase(
        name: 'Simple isolate example',
        builder: (_) => GameWidget(
          game: SimpleIsolateExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_isolate/simple_isolate_example.dart',
        ),
        info: SimpleIsolateExample.description,
      ),
    ],
  );
}
