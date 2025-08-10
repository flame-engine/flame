import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/router/router_world_example.dart';
import 'package:flame/game.dart';

void addRouterStories(Dashbook dashbook) {
  dashbook
      .storiesOf('Router')
      .add(
        'Router with multiple worlds',
        (_) => GameWidget(game: RouterWorldExample()),
        codeLink: baseLink('router/router_world_example.dart'),
        info: RouterWorldExample.description,
      );
}
