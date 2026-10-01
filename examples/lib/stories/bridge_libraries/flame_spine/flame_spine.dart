import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_spine/basic_spine_example.dart';
import 'package:examples/stories/bridge_libraries/flame_spine/shared_data_spine_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent flameSpineStories() {
  return WidgetbookComponent(
    name: 'FlameSpine',
    useCases: [
      ExampleUseCase(
        name: 'Basic Spine Animation',
        builder: (_) => GameWidget(
          game: FlameSpineExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_spine/basic_spine_example.dart',
        ),
        info: FlameSpineExample.description,
      ),
      ExampleUseCase(
        name: 'SpineComponent with shared data',
        builder: (_) => GameWidget(
          game: SharedDataSpineExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_spine/shared_data_spine_example.dart',
        ),
        info: SharedDataSpineExample.description,
      ),
    ],
  );
}
