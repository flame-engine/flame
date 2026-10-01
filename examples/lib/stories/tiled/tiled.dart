import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/tiled/flame_tiled_animation_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent tiledStories() {
  return WidgetbookComponent(
    name: 'Tiled',
    useCases: [
      ExampleUseCase(
        name: 'Flame Tiled Animation',
        builder: (_) => GameWidget(game: FlameTiledAnimationExample()),
        codeLink: baseLink('tiled/flame_tiled_animation_example.dart'),
        info: FlameTiledAnimationExample.description,
      ),
    ],
  );
}
