import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'composability.dart';
import 'debug.dart';
import 'priority.dart';

const priorityInfo = '''
On this example, click on the square to bring them to the front by changing the
priority.
''';

void addComponentsStories(Dashbook dashbook) {
  dashbook.storiesOf('Components')
    ..add(
      'Composability',
      (_) => GameWidget(game: Composability()),
      codeLink: baseLink('components/composability.dart'),
    )
    ..add(
      'Priority',
      (_) => GameWidget(game: Priority()),
      codeLink: baseLink('components/priority.dart'),
      info: priorityInfo,
    )
    ..add(
      'Debug',
      (_) => GameWidget(game: DebugGame()),
      codeLink: baseLink('components/debug.dart'),
    );
}
