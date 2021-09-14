import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'animation_group.dart';
import 'aseprite.dart';
import 'basic.dart';

const basicInfo = '''
Basic example of `SpriteAnimation`s use in Flame's `FlameGame`

The snippet shows how an animation can be loaded and added to the game
```
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final animation = await loadSpriteAnimation(
      'animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    final animationComponent = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(100.0),
    );

    add(animationComponent);
  }
}
```

On this example, click or touch anywhere on the screen to dynamically add animations
''';

void addAnimationStories(Dashbook dashbook) {
  dashbook.storiesOf('Animations')
    ..add(
      'Basic Animations',
      (_) => GameWidget(game: BasicAnimations()),
      codeLink: baseLink('animations/basic.dart'),
      info: basicInfo,
    )
    ..add(
      'Group animation',
      (_) => GameWidget(game: AnimationGroupExample()),
      codeLink: baseLink('animations/aseprite.dart'),
    )
    ..add(
      'Aseprite',
      (_) => GameWidget(game: Aseprite()),
      codeLink: baseLink('animations/aseprite.dart'),
    );
}
