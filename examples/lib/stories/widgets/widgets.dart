import 'package:dashbook/dashbook.dart';

import '../../commons/commons.dart';
import 'custom_painter_component.dart';
import 'nine_tile_box.dart';
import 'overlay.dart';
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
    )
    ..add(
      'Sprite Button',
      spriteButtonBuilder,
      codeLink: baseLink('widgets/sprite_button.dart'),
    )
    ..add(
      'Sprite Widget (full image)',
      spriteWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget.dart'),
    )
    ..add(
      'Sprite Widget (section of image)',
      spriteSectionWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget_section.dart'),
    )
    ..add(
      'Sprite Animation Widget',
      spriteAnimationWidgetBuilder,
      codeLink: baseLink('widgets/sprite_animation_widget.dart'),
    )
    ..add(
      'Overlay',
      overlayBuilder,
      codeLink: baseLink('widgets/overlay.dart'),
    )
    ..add(
      'CustomPainterComponent',
      customPainterBuilder,
      codeLink: baseLink('widgets/custom_painter_component.dart'),
      info: CustomPainterGame.info,
    );
}
