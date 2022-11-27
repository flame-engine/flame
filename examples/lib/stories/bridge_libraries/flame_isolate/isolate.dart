import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_isolate/simple_isolate_example.dart';
import 'package:flame/game.dart';

void addFlameIsolateExample(Dashbook dashbook) {
  dashbook.storiesOf('FlameIsolate').add(
        'Simple isolate example',
        (_) => GameWidget(
          game: SimpleIsolateExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_isolate/simple_isolate_example.dart',
        ),
        info: SimpleIsolateExample.description,
      );
}
