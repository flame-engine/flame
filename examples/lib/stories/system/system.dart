import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/system/overlays_example.dart';
import 'package:examples/stories/system/pause_resume_example.dart';
import 'package:examples/stories/system/resize_example.dart';
import 'package:examples/stories/system/step_engine_example.dart';
import 'package:examples/stories/system/without_flame_game_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent systemStories() {
  return WidgetbookComponent(
    name: 'System',
    useCases: [
      ExampleUseCase(
        name: 'Pause/resume engine',
        builder: (_) => GameWidget(game: PauseResumeExample()),
        codeLink: baseLink('system/pause_resume_example.dart'),
        info: PauseResumeExample.description,
      ),
      ExampleUseCase(
        name: 'Overlay',
        builder: (_) => const OverlaysExampleWidget(),
        codeLink: baseLink('system/overlays_example.dart'),
        info: OverlaysExample.description,
      ),
      ExampleUseCase(
        name: 'Without FlameGame',
        builder: (_) => GameWidget(game: NoFlameGameExample()),
        codeLink: baseLink('system/without_flame_game_example.dart'),
        info: NoFlameGameExample.description,
      ),
      ExampleUseCase(
        name: 'Step Game',
        builder: (_) => GameWidget(game: StepEngineExample()),
        codeLink: baseLink('system/step_engine_game.dart'),
        info: StepEngineExample.description,
      ),
      ExampleUseCase(
        name: 'On Game Resize',
        builder: (_) => GameWidget(game: ResizeExampleGame()),
        codeLink: baseLink('system/resize_example.dart'),
        info: ResizeExampleGame.description,
      ),
    ],
  );
}
