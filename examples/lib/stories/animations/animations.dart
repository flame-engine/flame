import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/animations/animation_group_example.dart';
import 'package:examples/stories/animations/aseprite_example.dart';
import 'package:examples/stories/animations/basic_animation_example.dart';
import 'package:examples/stories/animations/benchmark_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent animationStories() {
  return WidgetbookComponent(
    name: 'Animations',
    useCases: [
      ExampleUseCase(
        name: 'Basic Animations',
        builder: (_) => GameWidget(game: BasicAnimationsExample()),
        codeLink: baseLink('animations/basic_animation_example.dart'),
        info: BasicAnimationsExample.description,
      ),
      ExampleUseCase(
        name: 'Group animation',
        builder: (_) => GameWidget(game: AnimationGroupExample()),
        codeLink: baseLink('animations/animation_group_example.dart'),
        info: AnimationGroupExample.description,
      ),
      ExampleUseCase(
        name: 'Aseprite',
        builder: (_) => GameWidget(game: AsepriteExample()),
        codeLink: baseLink('animations/aseprite_example.dart'),
        info: AsepriteExample.description,
      ),
      ExampleUseCase(
        name: 'Benchmark',
        builder: (_) => GameWidget(game: BenchmarkExample()),
        codeLink: baseLink('animations/benchmark_example.dart'),
        info: BenchmarkExample.description,
      ),
    ],
  );
}
