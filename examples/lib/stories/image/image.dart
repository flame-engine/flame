import 'package:dashbook/dashbook.dart';

import 'package:examples/commons/commons.dart';
import 'package:examples/stories/image/resize.dart';
import 'package:flame/game.dart';

void addImageStories(Dashbook dashbook) {
  dashbook.storiesOf('Image')
    ..decorator(CenterDecorator())
    ..add(
      'resize',
      (context) => GameWidget(
        game: ImageResizeExample(
          Vector2(
            context.numberProperty('width', 200),
            context.numberProperty('height', 300),
          ),
        ),
      ),
      codeLink: baseLink('image/resize.dart'),
      info: '''
        Shows how a dart:ui `Image` can be resized using Flame Image extensions.
        Use the properties on the side to change the size of the image.
      ''',
    );
}
