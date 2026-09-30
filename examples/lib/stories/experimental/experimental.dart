import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/experimental/layout_component_example_1.dart';
import 'package:examples/stories/experimental/layout_component_example_2.dart';
import 'package:examples/stories/experimental/layout_component_example_3.dart';
import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:examples/stories/experimental/shapes.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent experimentalStories() {
  return WidgetbookComponent(
    name: 'Experimental',
    useCases: [
      ExampleUseCase(
        name: 'Shapes',
        builder: (_) => GameWidget(game: ShapesExample()),
        codeLink: baseLink('experimental/shapes.dart'),
        info: ShapesExample.description,
      ),
      ExampleUseCase(
        name: 'Layout Components 1',
        builder: (context) {
          return GameWidget(
            game: LayoutComponentExample1(
              mainAxisAlignment: context.knobs.object.dropdown(
                label: 'MainAxisAlignment',
                initialOption: MainAxisAlignment.values.first,
                options: MainAxisAlignment.values,
                labelBuilder: (value) => value.name,
              ),
              crossAxisAlignment: context.knobs.object.dropdown(
                label: 'CrossAxisAlignment',
                initialOption: CrossAxisAlignment.values.first,
                options: CrossAxisAlignment.values,
                labelBuilder: (value) => value.name,
              ),
              direction: context.knobs.object.dropdown(
                label: 'Direction',
                initialOption: Direction.values.first,
                options: Direction.values,
                labelBuilder: (value) => value.name,
              ),
              gap: context.knobs.double.input(
                label: 'Gap',
              ),
              demoSize: context.knobs.object.dropdown(
                label: 'Size',
                initialOption: LayoutComponentExampleSize.small,
                options: LayoutComponentExampleSize.values,
                labelBuilder: (size) => size.name,
              ),
              padding: EdgeInsets.fromLTRB(
                context.knobs.double.input(
                  label: 'Padding left',
                  initialValue: 10,
                ),
                context.knobs.double.input(
                  label: 'Padding top',
                  initialValue: 10,
                ),
                context.knobs.double.input(
                  label: 'Padding right',
                  initialValue: 10,
                ),
                context.knobs.double.input(
                  label: 'Padding bottom',
                  initialValue: 10,
                ),
              ),
              expandedMode: context.knobs.boolean(
                label: 'Wrap with ExpandedComponent',
              ),
              paddingInflateChild: context.knobs.boolean(
                label: 'Padding Component inflates child',
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample1.description,
      ),
      ExampleUseCase(
        name: 'Layout Components 2',
        builder: (context) {
          return GameWidget(
            game: LayoutComponentExample2(
              mainAxisAlignment: context.knobs.object.dropdown(
                label: 'MainAxisAlignment',
                initialOption: MainAxisAlignment.values.first,
                options: MainAxisAlignment.values,
                labelBuilder: (value) => value.name,
              ),
              crossAxisAlignment: context.knobs.object.dropdown(
                label: 'CrossAxisAlignment',
                initialOption: CrossAxisAlignment.stretch,
                options: CrossAxisAlignment.values,
                labelBuilder: (value) => value.name,
              ),
              direction: context.knobs.object.dropdown(
                label: 'Direction',
                initialOption: Direction.values.first,
                options: Direction.values,
                labelBuilder: (value) => value.name,
              ),
              gap: context.knobs.double.input(
                label: 'Gap',
              ),
              demoSize: context.knobs.object.dropdown(
                label: 'Size',
                initialOption: LayoutComponentExampleSize.small,
                options: LayoutComponentExampleSize.values,
                labelBuilder: (size) => size.name,
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample2.description,
      ),
      ExampleUseCase(
        name: 'Layout Components 3',
        builder: (context) {
          return GameWidget(
            game: LayoutComponentExample3(
              demoSize: context.knobs.object.dropdown(
                label: 'Size',
                initialOption: LayoutComponentExampleSize.small,
                options: LayoutComponentExampleSize.values,
                labelBuilder: (size) => size.name,
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample3.description,
      ),
    ],
  );
}
