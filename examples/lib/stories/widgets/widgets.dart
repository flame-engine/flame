import 'package:dashbook/dashbook.dart';

import '../../commons/commons.dart';
import 'custom_painter_example.dart';
import 'nine_tile_box_example.dart';
import 'partial_sprite_widget_example.dart';
import 'sprite_animation_widget_example.dart';
import 'sprite_button_example.dart';
import 'sprite_widget_example.dart';

void addWidgetsStories(Dashbook dashbook) {
  dashbook.storiesOf('Widgets')
    ..decorator(CenterDecorator())
    ..add(
      'Nine Tile Box',
      nineTileBoxBuilder,
      codeLink: baseLink('widgets/nine_tile_box_example.dart'),
      info: '''
        If you want to create a background for something that can stretch you
        can use the `NineTileBox` which is showcased here, don't forget to check
        out the settings on the pen icon.
      ''',
    )
    ..add(
      'Sprite Button',
      spriteButtonBuilder,
      codeLink: baseLink('widgets/sprite_button_example.dart'),
      info: '''
        If you want to use sprites as a buttons within the flutter widget tree
        you can create a `SpriteButton`, don't forget to check out the settings
        on the pen icon.
      ''',
    )
    ..add(
      'Sprite Widget (full image)',
      spriteWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget_example.dart'),
      info: '''
        If you want to use a sprite within the flutter widget tree
        you can create a `SpriteWidget`, don't forget to check out the settings
        on the pen icon.
      ''',
    )
    ..add(
      'Sprite Widget (section of image)',
      partialSpriteWidgetBuilder,
      codeLink: baseLink('widgets/partial_sprite_widget_example.dart'),
      info: '''
        In this example we show how you can render only parts of a sprite within
        a `SpriteWidget`, don't forget to check out the settings on the pen
        icon.
      ''',
    )
    ..add(
      'Sprite Animation Widget',
      spriteAnimationWidgetBuilder,
      codeLink: baseLink('widgets/sprite_animation_widget_example.dart'),
      info: '''
        If you want to use a sprite animation directly on the flutter widget
        tree you can create a `SpriteAnimationWidget`, don't forget to check out
        the settings on the pen icon.
      ''',
    )
    ..add(
      'CustomPainterComponent',
      customPainterBuilder,
      codeLink: baseLink('widgets/custom_painter_example.dart'),
      info: CustomPainterExample.description,
    );
}
