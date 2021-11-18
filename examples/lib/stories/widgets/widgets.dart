import 'package:dashbook/dashbook.dart';

import '../../commons/commons.dart';
import 'custom_painter_component.dart';
import 'nine_tile_box.dart';
import 'sprite_animation_widget.dart';
import 'sprite_button.dart';
import 'sprite_widget.dart';
import 'sprite_widget_section.dart';

void addWidgetsStories(Dashbook dashbook) {
  dashbook.storiesOf('Widgets')
    ..decorator(CenterDecorator())
    ..add(
      'Nine Tile Box',
      nineTileBoxBuilder,
      codeLink: baseLink('widgets/nine_tile_box.dart'),
      info: '''
        If you want to create a background for something that can stretch you
        can use the `NineTileBox` which is showcased here, don't forget to check
        out the settings on the pen icon.
      ''',
    )
    ..add(
      'Sprite Button',
      spriteButtonBuilder,
      codeLink: baseLink('widgets/sprite_button.dart'),
      info: '''
        If you want to use sprites as a buttons within the flutter widget tree
        you can create a `SpriteButton`, don't forget to check out the settings
        on the pen icon.
      ''',
    )
    ..add(
      'Sprite Widget (full image)',
      spriteWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget.dart'),
      info: '''
        If you want to use a sprite within the flutter widget tree
        you can create a `SpriteWidget`, don't forget to check out the settings
        on the pen icon.
      ''',
    )
    ..add(
      'Sprite Widget (section of image)',
      spriteSectionWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget_section.dart'),
      info: '''
        In this example we show how you can render only parts of a sprite within
        a `SpriteWidget`, don't forget to check out the settings on the pen
        icon.
      ''',
    )
    ..add(
      'Sprite Animation Widget',
      spriteAnimationWidgetBuilder,
      codeLink: baseLink('widgets/sprite_animation_widget.dart'),
      info: '''
        If you want to use a sprite animation directly on the flutter widget
        tree you can create a `SpriteAnimationWidget`, don't forget to check out
        the settings on the pen icon.
      ''',
    )
    ..add(
      'CustomPainterComponent',
      customPainterBuilder,
      codeLink: baseLink('widgets/custom_painter_component.dart'),
      info: CustomPainterExample.description,
    );
}
