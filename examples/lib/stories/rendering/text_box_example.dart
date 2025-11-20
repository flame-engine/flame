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
  static const String description = 'Some TextBoxComponent behaviors';

  final textBoxComponent = TextBoxComponent(
    text: 'The quick brown fox jumps over the lazy dog.',
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

  static const lipsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent at '
      'ante ornare, eleifend purus sollicitudin, imperdiet metus. Vestibulum '
      'egestas tortor in ipsum lacinia molestie. Donec at sapien placerat, '
      'dignissim eros et, eleifend erat. Interdum et malesuada fames ac ante '
      'ipsum primis in faucibus. Donec blandit risus non purus fringilla '
      'accumsan. Proin ornare eleifend risus, in placerat augue semper id. '
      'Phasellus eu ex neque. Integer dignissim elit non augue cursus laoreet '
      'et eu nulla. Pellentesque vitae interdum nunc, sit amet facilisis dui. '
      'Suspendisse in augue ut velit varius aliquam. Aenean in orci laoreet, '
      'blandit purus at, tempor purus. Suspendisse potenti.';
}
