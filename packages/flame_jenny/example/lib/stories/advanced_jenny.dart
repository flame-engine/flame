import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:jenny_example/commons/commons.dart';

void addJennyAdvancedExample(Dashbook dashbook) {
  dashbook.storiesOf('JennyAdvanced').add(
        'Advanced Jenny example',
        (_) => GameWidget(
          game: JennyAdvancedExample(),
        ),
        codeLink: baseLink(
          'example/lib/stories/advanced_jenny.dart',
        ),
        info: JennyAdvancedExample.description,
      );
}

class JennyAdvancedExample extends FlameGame {
  static const String description = '''
    This example shows how to use the Jenny API. .
  ''';

  @override
  Future<void> onLoad() async {}
}
