import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_lottie/lottie_animation_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent flameLottieStories() {
  return WidgetbookComponent(
    name: 'FlameLottie',
    useCases: [
      ExampleUseCase(
        name: 'Lottie Animation example',
        builder: (_) => GameWidget(
          game: LottieAnimationExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_lottie/lottie_animation_example.dart',
        ),
        info: LottieAnimationExample.description,
      ),
    ],
  );
}
