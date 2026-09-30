import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/image/brighten.dart';
import 'package:examples/stories/image/darken.dart';
import 'package:examples/stories/image/resize.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent imageStories() {
  return WidgetbookComponent(
    name: 'Image',
    useCases: [
      ExampleUseCase(
        name: 'resize',
        builder: (context) => GameWidget(
          game: ImageResizeExample(
            Vector2(
              context.knobs.double.input(
                label: 'width',
                initialValue: 200,
              ),
              context.knobs.double.input(
                label: 'height',
                initialValue: 300,
              ),
            ),
          ),
        ),
        codeLink: baseLink('image/resize.dart'),
        info: ImageResizeExample.description,
      ),
      ExampleUseCase(
        name: 'brightness',
        builder: (context) => GameWidget(
          game: ImageBrightnessExample(
            brightness: context.knobs.double.input(
              label: 'brightness',
              initialValue: 80,
            ),
          ),
        ),
        codeLink: baseLink('image/brighten.dart'),
        info: ImageBrightnessExample.description,
      ),
      ExampleUseCase(
        name: 'darkness',
        builder: (context) => GameWidget(
          game: ImageDarknessExample(
            darkness: context.knobs.double.input(
              label: 'darkness',
              initialValue: 80,
            ),
          ),
        ),
        codeLink: baseLink('image/darkness.dart'),
        info: ImageDarknessExample.description,
      ),
    ],
  );
}
