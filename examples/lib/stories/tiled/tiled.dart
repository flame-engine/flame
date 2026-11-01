import 'package:examples/commons/commons.dart';
import 'package:examples/commons/culling_story.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/tiled/flame_tiled_animation_example.dart';
import 'package:examples/stories/tiled/tiled_culling_example.dart';
import 'package:examples/stories/tiled/tiled_culling_visualized_example.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
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
        builder: (context) {
          final knobs = _tiledCullingKnobs(context);
          return CullingStory(
            gameKey: knobs.gameKey,
            createGame: () => TiledCullingExample(
              culled: knobs.culled,
              orientation: knobs.orientation,
              chunkSize: knobs.chunkSize,
              cameraSpeed: knobs.cameraSpeed,
            ),
            apply: (game) => game
              ..culled = knobs.culled
              ..cameraSpeed = knobs.cameraSpeed,
          );
        },
        codeLink: baseLink('tiled/tiled_culling_example.dart'),
        info: TiledCullingExample.description,
      ),
      ExampleUseCase(
        name: 'Tiled Culling (visualized)',
        builder: (context) {
          final knobs = _tiledCullingKnobs(context, withBigView: true);
          return CullingStory(
            gameKey: knobs.gameKey,
            createGame: () => TiledCullingVisualizedExample(
              culled: knobs.culled,
              orientation: knobs.orientation,
              chunkSize: knobs.chunkSize,
              cameraSpeed: knobs.cameraSpeed,
              bigView: knobs.bigView,
            ),
            apply: (game) => game
              ..culled = knobs.culled
              ..cameraSpeed = knobs.cameraSpeed
              ..bigView = knobs.bigView,
          );
        },
        codeLink: baseLink('tiled/tiled_culling_visualized_example.dart'),
        info: TiledCullingVisualizedExample.description,
      ),
    ],
  );
}

/// The values of the knobs of the Tiled culling examples, and `gameKey`: the
/// knobs that need a new map, and so a new game, when they change.
typedef _TiledCullingKnobs = ({
  bool culled,
  bool bigView,
  TiledCullingOrientation orientation,
  int chunkSize,
  double cameraSpeed,
  Object gameKey,
});

/// The knobs of the Tiled culling examples, in the order that they are shown:
/// the toggles first, and then the other settings.
///
/// The "Big view" knob is only added [withBigView], and is otherwise always on.
_TiledCullingKnobs _tiledCullingKnobs(
  BuildContext context, {
  bool withBigView = false,
}) {
  final culled = context.knobs.boolean(
    label: cullingCulledKnob,
    initialValue: true,
  );
  final bigView =
      !withBigView ||
      context.knobs.boolean(label: cullingBigViewKnob, initialValue: true);
  final orientation = context.knobs.object.dropdown(
    label: 'Orientation',
    initialOption: TiledCullingOrientation.orthogonal,
    options: TiledCullingOrientation.values,
    labelBuilder: (value) => value.label,
  );
  final chunkSize = context.knobs.object.dropdown(
    label: 'Chunk size',
    initialOption: tiledCullingChunkSize,
    options: tiledCullingChunkSizes,
    labelBuilder: (size) => '$size x $size tiles',
  );
  return (
    culled: culled,
    bigView: bigView,
    orientation: orientation,
    chunkSize: chunkSize,
    cameraSpeed: cameraSpeedKnob(context),
    // A new map, and so a new game, is needed when these change.
    gameKey: (orientation, chunkSize),
  );
}
