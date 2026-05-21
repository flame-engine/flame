import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

enum TextBoxConfigMaxWidth {
  small(200),
  large(640);

  const TextBoxConfigMaxWidth(this.value);

  final double value;
}

class TextBoxExample extends FlameGame {
  static const String description =
      'TextBoxComponent reflows text when boxConfig.maxWidth is changed';

  final textBoxComponent = TextBoxComponent(
    text: sampleText,
  )..debugMode = true;

  TextBoxConfigMaxWidth currentWidth = TextBoxConfigMaxWidth.small;

  @override
  FutureOr<void> onLoad() {
    add(
      ColumnComponent(
        position: Vector2(0, 48),
        children: [
          TextComponent(text: 'TextBoxComponent changes'),
          ButtonComponent(
            button: TextComponent(
              text: '[Toggle Between Sizes]',
            ),
            onReleased: () {
              currentWidth = currentWidth == TextBoxConfigMaxWidth.small
                  ? TextBoxConfigMaxWidth.large
                  : TextBoxConfigMaxWidth.small;
              textBoxComponent.boxConfig = textBoxComponent.boxConfig.copyWith(
                maxWidth: currentWidth.value,
              );
              textBoxComponent.redraw();
            },
          ),
          textBoxComponent,
        ],
      ),
    );
  }

  static const sampleText =
      'In a bustling city, a small team of developers set out to create '
      'a mobile game using the Flame engine for Flutter. Their goal was '
      'simple: to create an engaging, easy-to-play game that could reach '
      'a wide audience on both iOS and Android platforms. '
      'After weeks of brainstorming, they decided on a concept: '
      'a fast-paced, endless runner game set in a whimsical, '
      'ever-changing world. They named it "Swift Dash." '
      "Using Flutter's versatility and the Flame engine's "
      'capabilities, the team crafted a game with vibrant graphics, '
      'smooth animations, and responsive controls. '
      'The game featured a character dashing through various landscapes, '
      'dodging obstacles, and collecting points. '
      'As they launched "Swift Dash," the team was anxious but hopeful. '
      'To their delight, the game was well-received. Players loved its '
      'simplicity and charm, and the game quickly gained popularity.';
}
