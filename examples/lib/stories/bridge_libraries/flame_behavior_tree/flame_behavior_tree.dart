import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/basic_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/race_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/robot_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/switch_tree_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/thief_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/tick_interval_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/traffic_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/turret_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

String _link(String example) {
  return baseLink('bridge_libraries/flame_behavior_tree/$example');
}

WidgetbookComponent flameBehaviorTreeStories() {
  return WidgetbookComponent(
    name: 'flame_behavior_tree',
    useCases: [
      ExampleUseCase(
        name: 'Basic example',
        builder: (_) => GameWidget(game: BasicExample()),
        codeLink: _link('basic_example.dart'),
        info: BasicExample.description,
      ),
      ExampleUseCase(
        name: 'Robot (leaf nodes)',
        builder: (_) => GameWidget(game: RobotExample()),
        codeLink: _link('robot_example.dart'),
        info: RobotExample.description,
      ),
      ExampleUseCase(
        name: 'Traffic (sequence memory)',
        builder: (_) => GameWidget(game: TrafficExample()),
        codeLink: _link('traffic_example.dart'),
        info: TrafficExample.description,
      ),
      ExampleUseCase(
        name: 'Turret (Cooldown, Repeat, Inverter)',
        builder: (_) => GameWidget(game: TurretExample()),
        codeLink: _link('turret_example.dart'),
        info: TurretExample.description,
      ),
      ExampleUseCase(
        name: 'Thief (RetryOnFailure, TimeLimit, AlwaysSucceed)',
        builder: (_) => GameWidget(game: ThiefExample()),
        codeLink: _link('thief_example.dart'),
        info: ThiefExample.description,
      ),
      ExampleUseCase(
        name: 'Race (Parallel)',
        builder: (_) => GameWidget(game: RaceExample()),
        codeLink: _link('race_example.dart'),
        info: RaceExample.description,
      ),
      ExampleUseCase(
        name: 'Tick interval',
        builder: (_) => GameWidget(game: TickIntervalExample()),
        codeLink: _link('tick_interval_example.dart'),
        info: TickIntervalExample.description,
      ),
      ExampleUseCase(
        name: 'Switching trees',
        builder: (_) => GameWidget(game: SwitchTreeExample()),
        codeLink: _link('switch_tree_example.dart'),
        info: SwitchTreeExample.description,
      ),
    ],
  );
}
