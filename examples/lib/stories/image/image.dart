import 'package:dashbook/dashbook.dart';

import 'package:examples/commons/commons.dart';
import 'package:examples/stories/image/brighten.dart';
import 'package:examples/stories/image/darken.dart';
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
      info: ImageResizeExample.description,
    )
    ..add(
      'brightness',
      (context) => GameWidget(
        game: ImageBrightnessExample(
          brightness: context.numberProperty('brightness', 80),
        ),
      ),
      codeLink: baseLink('image/brighten.dart'),
      info: ImageBrightnessExample.description,
    )
    ..add(
      'darkness',
      (context) => GameWidget(
        game: ImageDarknessExample(
          darkness: context.numberProperty('darkness', 80),
        ),
      ),
      codeLink: baseLink('image/darkness.dart'),
      info: ImageDarknessExample.description,
    );
}
