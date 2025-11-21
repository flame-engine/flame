import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/experimental/layout_component_example_1.dart';
import 'package:examples/stories/experimental/layout_component_example_2.dart';
import 'package:examples/stories/experimental/layout_component_example_3.dart';
import 'package:examples/stories/experimental/layout_component_example_size.dart';
import 'package:examples/stories/experimental/shapes.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/rendering.dart';

void addExperimentalStories(Dashbook dashbook) {
  dashbook
      .storiesOf('Experimental')
      .add(
        'Shapes',
        (_) => GameWidget(game: ShapesExample()),
        codeLink: baseLink('experimental/shapes.dart'),
        info: ShapesExample.description,
      )
      .add(
        'Layout Components 1',
        (DashbookContext context) {
          return GameWidget(
            game: LayoutComponentExample1(
              mainAxisAlignment: context.listProperty(
                'MainAxisAlignment',
                MainAxisAlignment.values.first,
                MainAxisAlignment.values,
              ),
              crossAxisAlignment: context.listProperty(
                'CrossAxisAlignment',
                CrossAxisAlignment.values.first,
                CrossAxisAlignment.values,
              ),
              direction: context.listProperty(
                'Direction',
                Direction.values.first,
                Direction.values,
              ),
              gap: context.numberProperty('Gap', 0),
              demoSize: context.optionsProperty<LayoutComponentExampleSize>(
                'Size',
                LayoutComponentExampleSize.small,
                LayoutComponentExampleSize.values.map((exampleSize) {
                  return PropertyOption(exampleSize.name, exampleSize);
                }).toList(),
              ),
              padding: context.edgeInsetsProperty(
                'Padding',
                const EdgeInsets.all(10),
              ),
              expandedMode: context.boolProperty(
                'Wrap with ExpandedComponent',
                false,
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample1.description,
      )
      .add(
        'Layout Components 2',
        (DashbookContext context) {
          return GameWidget(
            game: LayoutComponentExample2(
              mainAxisAlignment: context.listProperty(
                'MainAxisAlignment',
                MainAxisAlignment.values.first,
                MainAxisAlignment.values,
              ),
              crossAxisAlignment: context.listProperty(
                'CrossAxisAlignment',
                CrossAxisAlignment.stretch,
                CrossAxisAlignment.values,
              ),
              direction: context.listProperty(
                'Direction',
                Direction.values.first,
                Direction.values,
              ),
              gap: context.numberProperty('Gap', 0),
              demoSize: context.optionsProperty<LayoutComponentExampleSize>(
                'Size',
                LayoutComponentExampleSize.small,
                LayoutComponentExampleSize.values.map((exampleSize) {
                  return PropertyOption(exampleSize.name, exampleSize);
                }).toList(),
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample2.description,
      )
      .add(
        'Layout Components 3',
        (DashbookContext context) {
          return GameWidget(
            game: LayoutComponentExample3(
              demoSize: context.optionsProperty<LayoutComponentExampleSize>(
                'Size',
                LayoutComponentExampleSize.small,
                LayoutComponentExampleSize.values.map((exampleSize) {
                  return PropertyOption(exampleSize.name, exampleSize);
                }).toList(),
              ),
            ),
          );
        },
        codeLink: baseLink('experimental/layout_components.dart'),
        info: LayoutComponentExample3.description,
      );
}
