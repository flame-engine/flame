import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_flutter3d/post_processing_example.dart';
import 'package:examples/stories/bridge_libraries/flame_flutter3d/shared_loop_example.dart';
import 'package:examples/stories/bridge_libraries/flame_flutter3d/story_host.dart';
import 'package:examples/stories/bridge_libraries/flame_flutter3d/tiled_maze_example.dart';
import 'package:widgetbook/widgetbook.dart';

String _link(String example) =>
    baseLink('bridge_libraries/flame_flutter3d/$example');

WidgetbookComponent flameFlutter3dStories() {
  return WidgetbookComponent(
    name: 'flame_flutter3d',
    useCases: [
      ExampleUseCase(
        name: 'Post-processing',
        builder: (_) => const Flutter3dStory(
          create: PostProcessingExample.new,
          overlays: {'panel': PostProcessingExample.panel},
        ),
        codeLink: _link('post_processing_example.dart'),
        info: PostProcessingExample.description,
      ),
      ExampleUseCase(
        name: 'One loop for both engines',
        builder: (_) => const Flutter3dStory(create: SharedLoopExample.new),
        codeLink: _link('shared_loop_example.dart'),
        info: SharedLoopExample.description,
      ),
      ExampleUseCase(
        name: 'Tiled map in 3D',
        builder: (_) => const Flutter3dStory(create: TiledMazeExample.new),
        codeLink: _link('tiled_maze_example.dart'),
        info: TiledMazeExample.description,
      ),
    ],
  );
}
