import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_spine/basic_spine_example.dart';
import 'package:examples/stories/bridge_libraries/flame_spine/shared_data_spine_example.dart';
import 'package:flame/game.dart';

void addFlameSpineExamples(Dashbook dashbook) {
  dashbook.storiesOf('FlameSpine')
    ..add(
      'Basic Spine Animation',
      (_) => GameWidget(
        game: FlameSpineExample(),
      ),
      codeLink:
          baseLink('bridge_libraries/flame_spine/basic_spine_example.dart'),
      info: FlameSpineExample.description,
    )
    ..add(
      'SpineComponent with shared data',
      (_) => GameWidget(
        game: SharedDataSpineExample(),
      ),
      codeLink: baseLink(
        'bridge_libraries/flame_spine/shared_data_spine_example.dart',
      ),
      info: SharedDataSpineExample.description,
    );
}
