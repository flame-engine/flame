import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_lottie/lottie_animation_example.dart';
import 'package:flame/game.dart';

void addFlameLottieExample(Dashbook dashbook) {
  dashbook.storiesOf('FlameLottie').add(
        'Lottie Animation example',
        (_) => GameWidget(
          game: LottieAnimationExample(),
        ),
        codeLink: baseLink(
          'bridge_libraries/flame_lottie/lottie_animation_example.dart',
        ),
        info: LottieAnimationExample.description,
      );
}
