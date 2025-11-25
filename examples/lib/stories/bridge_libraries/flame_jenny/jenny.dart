import 'package:dashbook/dashbook.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_advanced_example.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_command_lifecycle_example.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_simple_example.dart';
import 'package:flame/game.dart';

void addFlameJennyExample(Dashbook dashbook) {
  dashbook.storiesOf('FlameJenny')
    ..add(
      'Simple Jenny example',
      (_) => GameWidget(game: JennySimpleExample()),
      codeLink: baseLink('jenny_simple_example.dart'),
      info: JennySimpleExample.description,
    )
    ..add(
      'Advanced Jenny example',
      (_) => GameWidget(game: JennyAdvancedExample()),
      codeLink: baseLink('jenny_advanced_example.dart'),
      info: JennyAdvancedExample.description,
    )
    ..add(
      'Command Lifecycle example',
      (_) => GameWidget(game: JennyCommandLifecycleExample()),
      codeLink: baseLink('jenny_command_lifecycle_example.dart'),
      info: JennyCommandLifecycleExample.description,
    );
}
