import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_advanced_example.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_command_lifecycle_example.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_simple_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent flameJennyStories() {
  return WidgetbookComponent(
    name: 'FlameJenny',
    useCases: [
      ExampleUseCase(
        name: 'Simple Jenny example',
        builder: (_) => GameWidget(game: JennySimpleExample()),
        codeLink: baseLink('jenny_simple_example.dart'),
        info: JennySimpleExample.description,
      ),
      ExampleUseCase(
        name: 'Advanced Jenny example',
        builder: (_) => GameWidget(game: JennyAdvancedExample()),
        codeLink: baseLink('jenny_advanced_example.dart'),
        info: JennyAdvancedExample.description,
      ),
      ExampleUseCase(
        name: 'Command Lifecycle example',
        builder: (_) => GameWidget(game: JennyCommandLifecycleExample()),
        codeLink: baseLink('jenny_command_lifecycle_example.dart'),
        info: JennyCommandLifecycleExample.description,
      ),
    ],
  );
}
