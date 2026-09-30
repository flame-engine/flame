import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/parallax/advanced_parallax_example.dart';
import 'package:examples/stories/parallax/animation_parallax_example.dart';
import 'package:examples/stories/parallax/basic_parallax_example.dart';
import 'package:examples/stories/parallax/component_parallax_example.dart';
import 'package:examples/stories/parallax/no_fcs_parallax_example.dart';
import 'package:examples/stories/parallax/sandbox_layer_parallax_example.dart';
import 'package:examples/stories/parallax/small_parallax_example.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent parallaxStories() {
  return WidgetbookComponent(
    name: 'Parallax',
    useCases: [
      ExampleUseCase(
        name: 'Basic',
        builder: (_) => GameWidget(game: BasicParallaxExample()),
        codeLink: baseLink('parallax/basic_parallax_example.dart'),
        info: BasicParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'Component',
        builder: (_) => GameWidget(game: ComponentParallaxExample()),
        codeLink: baseLink('parallax/component_parallax_example.dart'),
        info: ComponentParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'Animation',
        builder: (_) => GameWidget(game: AnimationParallaxExample()),
        codeLink: baseLink('parallax/animation_parallax_example.dart'),
        info: AnimationParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'Non-fullscreen',
        builder: (_) => GameWidget(game: SmallParallaxExample()),
        codeLink: baseLink('parallax/small_parallax_example.dart'),
        info: SmallParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'No FCS',
        builder: (_) => GameWidget(game: NoFCSParallaxExample()),
        codeLink: baseLink('parallax/no_fcs_parallax_example.dart'),
        info: NoFCSParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'Advanced',
        builder: (_) => GameWidget(game: AdvancedParallaxExample()),
        codeLink: baseLink('parallax/advanced_parallax_example.dart'),
        info: AdvancedParallaxExample.description,
      ),
      ExampleUseCase(
        name: 'Layer sandbox',
        builder: (context) {
          return GameWidget(
            game: SandboxLayerParallaxExample(
              planeSpeed: Vector2(
                context.knobs.double.input(
                  label: 'plane x speed',
                ),
                context.knobs.double.input(
                  label: 'plane y speed',
                ),
              ),
              planeRepeat: context.knobs.object.dropdown(
                label: 'plane repeat strategy',
                initialOption: ImageRepeat.noRepeat,
                options: ImageRepeat.values,
                labelBuilder: (value) => value.name,
              ),
              planeFill: context.knobs.object.dropdown(
                label: 'plane fill strategy',
                initialOption: LayerFill.none,
                options: LayerFill.values,
                labelBuilder: (value) => value.name,
              ),
              planeAlignment: context.knobs.object.dropdown(
                label: 'plane alignment strategy',
                initialOption: Alignment.center,
                options: [
                  Alignment.topLeft,
                  Alignment.topRight,
                  Alignment.center,
                  Alignment.topCenter,
                  Alignment.centerLeft,
                  Alignment.bottomLeft,
                  Alignment.bottomRight,
                  Alignment.bottomCenter,
                ],
              ),
            ),
          );
        },
        codeLink: baseLink('parallax/sandbox_layer_parallax_example.dart'),
        info: SandboxLayerParallaxExample.description,
      ),
    ],
  );
}
