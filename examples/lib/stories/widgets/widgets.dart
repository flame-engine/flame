import 'package:dashbook/dashbook.dart';

import '../../commons/commons.dart';
import 'nine_tile_box.dart';
import 'overlay.dart';
import 'sprite_animation_widget.dart';
import 'sprite_button.dart';
import 'sprite_widget.dart';

void addWidgetsStories(Dashbook dashbook) {
  dashbook.storiesOf('Widgets')
    ..decorator(CenterDecorator())
    ..add(
      'Nine Tile Box',
      nineTileBoxBuilder,
      codeLink: baseLink('widgets/nine-box.dart'),
    )
    ..add(
      'Sprite Button',
      spriteButtonBuilder,
      codeLink: baseLink('widgets/sprite_button.dart'),
    )
    ..add(
      'Sprite Widget',
      spriteWidgetBuilder,
      codeLink: baseLink('widgets/sprite_widget.dart'),
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
    );
}
