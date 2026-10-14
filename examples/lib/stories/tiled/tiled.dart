import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/tiled/flame_tiled_animation_example.dart';
import 'package:examples/stories/tiled/tiled_culling_example.dart';
import 'package:examples/stories/tiled/tiled_culling_visualized_example.dart';
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
      ExampleUseCase(
        name: 'Tiled Culling',
        builder: (context) => GameWidget(
          game: TiledCullingExample(
            culled: context.knobs.boolean(
              label: 'Culled',
              initialValue: true,
            ),
            orientation: context.knobs.object.dropdown(
              label: 'Orientation',
              initialOption: TiledCullingOrientation.orthogonal,
              options: TiledCullingOrientation.values,
              labelBuilder: (value) => value.label,
            ),
          ),
        ),
        codeLink: baseLink('tiled/tiled_culling_example.dart'),
        info: TiledCullingExample.description,
      ),
      ExampleUseCase(
        name: 'Tiled Culling (visualized)',
        builder: (context) => GameWidget(
          game: TiledCullingVisualizedExample(
            culled: context.knobs.boolean(
              label: 'Culled',
              initialValue: true,
            ),
            orientation: context.knobs.object.dropdown(
              label: 'Orientation',
              initialOption: TiledCullingOrientation.orthogonal,
              options: TiledCullingOrientation.values,
              labelBuilder: (value) => value.label,
            ),
          ),
        ),
        codeLink: baseLink('tiled/tiled_culling_visualized_example.dart'),
        info: TiledCullingVisualizedExample.description,
      ),
    ],
  );
}
