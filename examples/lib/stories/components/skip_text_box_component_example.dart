import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class SkipTextBoxComponentExample extends FlameGame {
  static const String description = '''
    On this example, click on the "Skip" button to display all the text at once.
  ''';

  @override
  FutureOr<void> onLoad() {
    final textBoxComponent = TextBoxComponent(
      text: loremIpsum,
      position: Vector2(48, 48 * 2),
      boxConfig: const TextBoxConfig(
        maxWidth: 480,
        timePerChar: 0.01,
      ),
    );
    addAll([
      ButtonComponent(
        position: Vector2(48, 48),
        button: TextComponent(text: 'Skip'),
        onReleased: textBoxComponent.skip,
      ),
      textBoxComponent,
    ]);
  }

  static const String loremIpsum = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc porttitor vel dui efficitur venenatis. Praesent justo lectus, vestibulum vel erat in, placerat pharetra enim. Proin molestie congue augue, id lacinia mi. Nulla enim urna, imperdiet a lectus quis, venenatis commodo orci. Ut vitae luctus nulla. Integer eu tellus justo. Vivamus interdum nibh eget justo auctor porttitor. Proin interdum ligula massa, ac fermentum velit posuere in. In eu lacus vel ante euismod imperdiet. Pellentesque a mauris lacus. Nullam et lacus id sem tempus faucibus. Vivamus quis lacinia arcu. Integer condimentum non velit non tristique. Donec dapibus ipsum ac ipsum eleifend, blandit luctus purus efficitur. Donec tempus et arcu eu lobortis.

Ut vel tellus elit. Fusce id urna quis mi maximus sodales sed a lorem. Nam auctor faucibus eros sed tempor. Pellentesque non nunc blandit erat venenatis tincidunt eu vitae sapien. Fusce semper tincidunt ultricies. Vivamus sed felis et lacus lobortis pharetra. Nulla suscipit, elit a luctus faucibus, dolor orci consectetur elit, a bibendum dolor justo sit amet lectus. Pellentesque malesuada placerat tortor nec sollicitudin. Nunc eu ex consectetur, suscipit urna efficitur, congue tortor. Donec luctus vel eros et feugiat. In feugiat, nunc non pharetra pulvinar, velit nisi malesuada purus, ut blandit metus ex ac libero. Sed gravida turpis in eleifend interdum.

Suspendisse potenti. Cras nec bibendum orci. Integer lacinia vel enim non dapibus. Maecenas eleifend mi ut sodales ultrices. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nunc sed felis massa. Etiam blandit sollicitudin erat, nec hendrerit tellus luctus eget. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer mollis et felis sed tempus. Nam in tellus tortor. Aliquam rutrum, sapien vitae lacinia sagittis, sapien purus interdum ligula, at hendrerit velit neque sit amet nisi. Aliquam nec erat eu sapien efficitur rhoncus. Maecenas condimentum elementum dui. Praesent commodo euismod commodo.

In dapibus elementum semper. Curabitur et congue neque, tempus ullamcorper dui. Nunc ut mi pharetra, interdum nulla eu, pellentesque dolor. Vivamus ante lectus, efficitur et diam facilisis, tincidunt efficitur enim. Etiam lorem tellus, vehicula at hendrerit a, posuere sed nisl. In et sem vehicula, aliquam eros sit amet, suscipit ante. Suspendisse finibus sodales mi, eget scelerisque sem egestas non. Sed sagittis at urna ac scelerisque. Proin mollis lectus vitae nisi ullamcorper, sit amet semper sapien aliquet. Cras fringilla tellus sit amet tincidunt interdum. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aenean molestie cursus aliquet. Fusce finibus lobortis est, sed iaculis nisi placerat aliquam. Phasellus mollis lorem vel turpis rutrum, fermentum euismod dui porttitor. Nullam mollis ante eu leo commodo faucibus in vitae nisi.

Mauris quis convallis neque. Sed blandit dapibus libero, a euismod nunc accumsan non. Pellentesque cursus sem egestas, bibendum arcu sit amet, rhoncus nulla. Cras eleifend enim ut nisi consectetur, in dignissim lorem auctor. Proin id odio facilisis, lobortis justo quis, congue libero. Quisque scelerisque facilisis purus. Nunc turpis ex, tempor id ligula at, accumsan semper tellus. Donec aliquet vestibulum lorem ut facilisis. Donec tempus maximus tellus, nec sollicitudin arcu condimentum a. Morbi a libero eu magna dictum luctus. Mauris sed mollis orci. Duis a lacinia tellus, sed tristique tortor. Duis vestibulum nulla libero, in mollis mi iaculis sit amet.
''';
}
