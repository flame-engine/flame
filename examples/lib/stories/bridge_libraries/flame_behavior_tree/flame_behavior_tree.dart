import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/basic_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/decorators_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/leaf_nodes_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/memory_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/parallel_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/switch_tree_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/tick_interval_example.dart';
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
        name: 'Leaf nodes',
        builder: (_) => GameWidget(game: LeafNodesExample()),
        codeLink: _link('leaf_nodes_example.dart'),
        info: LeafNodesExample.description,
      ),
      ExampleUseCase(
        name: 'Sequence memory',
        builder: (_) => GameWidget(game: MemoryExample()),
        codeLink: _link('memory_example.dart'),
        info: MemoryExample.description,
      ),
      ExampleUseCase(
        name: 'Decorators',
        builder: (_) => GameWidget(game: DecoratorsExample()),
        codeLink: _link('decorators_example.dart'),
        info: DecoratorsExample.description,
      ),
      ExampleUseCase(
        name: 'Parallel',
        builder: (_) => GameWidget(game: ParallelExample()),
        codeLink: _link('parallel_example.dart'),
        info: ParallelExample.description,
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
