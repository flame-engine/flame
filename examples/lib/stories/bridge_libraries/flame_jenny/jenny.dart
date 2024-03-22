import 'package:dashbook/dashbook.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_advanced_example.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny_simple_example.dart';
import 'package:flame/game.dart';

void addJennySimpleExample(Dashbook dashbook) {
  dashbook.storiesOf('JennySimple').add(
    'Simple Jenny example',
        (_) => GameWidget(
      game: JennySimpleExample(),
    ),
    codeLink: baseLink(
      'example/lib/stories/simple_jenny.dart',
    ),
    info: JennySimpleExample.description,
  );
}


void addJennyAdvancedExample(Dashbook dashbook) {
  dashbook.storiesOf('JennySimple').add(
    'Advanced Jenny example',
        (_) => GameWidget(
      game: JennyAdvancedExample(),
    ),
    codeLink: baseLink(
      'example/lib/stories/simple_jenny.dart',
    ),
    info: JennyAdvancedExample.description,
  );
}