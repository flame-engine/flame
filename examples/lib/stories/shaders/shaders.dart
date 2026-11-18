import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/shaders/shader_placement_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent shadersStories() {
  return WidgetbookComponent(
    name: 'Shaders',
    useCases: [
      ExampleUseCase(
        name: 'Shader Placement',
        builder: (_) => GameWidget(game: ShaderPlacementExample()),
        codeLink: baseLink('shaders/shader_placement_example.dart'),
        info: ShaderPlacementExample.description,
      ),
    ],
  );
}
