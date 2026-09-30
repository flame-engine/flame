import 'dart:math';

import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/widgets/custom_painter_example.dart';
import 'package:examples/stories/widgets/nine_tile_box_example.dart';
import 'package:examples/stories/widgets/nine_tile_box_example_with_animation.dart';
import 'package:examples/stories/widgets/paints.dart';
import 'package:examples/stories/widgets/partial_sprite_widget_example.dart';
import 'package:examples/stories/widgets/sprite_animation_widget_example.dart';
import 'package:examples/stories/widgets/sprite_button_example.dart';
import 'package:examples/stories/widgets/sprite_widget_example.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

Anchor _anchorKnob(BuildContext context) {
  return context.knobs.object.dropdown(
    label: 'anchor',
    initialOption: Anchor.center,
    options: Anchor.values,
    labelBuilder: (anchor) => anchor.name,
  );
}

Paint? _paintKnob(BuildContext context) {
  return paintList[paintChoices.indexOf(
    context.knobs.object.dropdown(label: 'paint', options: paintChoices),
  )];
}

WidgetbookComponent widgetsStories() {
  return WidgetbookComponent(
    name: 'Widgets',
    useCases: [
      ExampleUseCase(
        name: 'Nine Tile Box',
        builder: (context) => Center(
          child: NineTileBoxWidgetExample(
            width: context.knobs.double.input(
              label: 'width',
              initialValue: 200,
            ),
            height: context.knobs.double.input(
              label: 'height',
              initialValue: 200,
            ),
          ),
        ),
        codeLink: baseLink('widgets/nine_tile_box_example.dart'),
        info: '''
        If you want to create a background for something that can stretch you
        can use the `NineTileBox` which is showcased here, don't forget to check
        out the settings in the knobs panel.
      ''',
      ),
      ExampleUseCase(
        name: 'Nine Tile Box (With animation widgets)',
        builder: (_) => const Center(
          child: AnimatedNineTileBoxWidgetExample(),
        ),
        codeLink: baseLink('widgets/nine_tile_box_example_with_animation.dart'),
        info: '''
        Similar to the Nine Tile Box example, but here a NineTileBoxWidget is composed
        with Flutter's AnimatedOpacity.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Button',
        builder: (context) => Center(
          child: SpriteButtonExample(
            width: context.knobs.double.input(
              label: 'width',
              initialValue: 250,
            ),
            height: context.knobs.double.input(
              label: 'height',
              initialValue: 75,
            ),
          ),
        ),
        codeLink: baseLink('widgets/sprite_button_example.dart'),
        info: '''
        If you want to use sprites as a buttons within the flutter widget tree
        you can create a `SpriteButton`, don't forget to check out the settings
        in the knobs panel.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Widget (full image)',
        builder: (context) => Center(
          child: SpriteWidgetExample(
            width: context.knobs.double.input(
              label: 'container width',
              initialValue: 400,
            ),
            height: context.knobs.double.input(
              label: 'container height',
              initialValue: 200,
            ),
            angle: pi / 180 * context.knobs.double.input(label: 'angle (deg)'),
            anchor: _anchorKnob(context),
            paint: _paintKnob(context),
          ),
        ),
        codeLink: baseLink('widgets/sprite_widget_example.dart'),
        info: '''
        If you want to use a sprite within the flutter widget tree
        you can create a `SpriteWidget`, don't forget to check out the settings
        in the knobs panel.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Widget (with size)',
        builder: (context) => Center(
          child: SizedSpriteWidgetExample(
            size: Size(
              context.knobs.double.input(label: 'width', initialValue: 400),
              context.knobs.double.input(label: 'height', initialValue: 200),
            ),
            angle: pi / 180 * context.knobs.double.input(label: 'angle (deg)'),
            anchor: _anchorKnob(context),
            paint: _paintKnob(context),
          ),
        ),
        codeLink: baseLink('widgets/sprite_widget_example.dart'),
        info: '''
Similar as the default example, but using a fixed size directly in the widget.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Widget (section of image)',
        builder: (context) => Center(
          child: PartialSpriteWidgetExample(
            width: context.knobs.double.input(
              label: 'container width',
              initialValue: 400,
            ),
            height: context.knobs.double.input(
              label: 'container height',
              initialValue: 200,
            ),
            srcPosition: Vector2(
              context.knobs.double.input(
                label: 'srcPosition.x',
                initialValue: 48,
              ),
              context.knobs.double.input(label: 'srcPosition.y'),
            ),
            srcSize: Vector2(
              context.knobs.double.input(label: 'srcSize.x', initialValue: 48),
              context.knobs.double.input(label: 'srcSize.y', initialValue: 32),
            ),
            anchor: _anchorKnob(context),
          ),
        ),
        codeLink: baseLink('widgets/partial_sprite_widget_example.dart'),
        info: '''
        In this example we show how you can render only parts of a sprite within
        a `SpriteWidget`, don't forget to check out the settings in the knobs
        panel.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Animation Widget',
        builder: (context) => Center(
          child: SpriteAnimationWidgetExample(
            width: context.knobs.double.input(
              label: 'container width',
              initialValue: 400,
            ),
            height: context.knobs.double.input(
              label: 'container height',
              initialValue: 200,
            ),
            playing: context.knobs.boolean(
              label: 'playing',
              initialValue: true,
            ),
            anchor: _anchorKnob(context),
            paint: _paintKnob(context),
          ),
        ),
        codeLink: baseLink('widgets/sprite_animation_widget_example.dart'),
        info: '''
        If you want to use a sprite animation directly on the flutter widget
        tree you can create a `SpriteAnimationWidget`, don't forget to check out
        the settings in the knobs panel.
      ''',
      ),
      ExampleUseCase(
        name: 'Sprite Animation Widget (with size)',
        builder: (context) => Center(
          child: SizedSpriteAnimationWidgetExample(
            size: Size(
              context.knobs.double.input(label: 'width', initialValue: 400),
              context.knobs.double.input(label: 'height', initialValue: 200),
            ),
            playing: context.knobs.boolean(
              label: 'playing',
              initialValue: true,
            ),
            anchor: _anchorKnob(context),
            paint: _paintKnob(context),
          ),
        ),
        codeLink: baseLink('widgets/sprite_animation_widget_example.dart'),
        info: '''
Similar as the default example, but using a fixed size directly in the widget.
      ''',
      ),
      ExampleUseCase(
        name: 'CustomPainterComponent',
        builder: (_) => const Center(child: CustomPainterExampleWidget()),
        codeLink: baseLink('widgets/custom_painter_example.dart'),
        info: CustomPainterExample.description,
      ),
    ],
  );
}
