import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/components/clip_component_example.dart';
import 'package:examples/stories/components/components_notifier_example.dart';
import 'package:examples/stories/components/components_notifier_provider_example.dart';
import 'package:examples/stories/components/composability_example.dart';
import 'package:examples/stories/components/debug_example.dart';
import 'package:examples/stories/components/has_visibility_example.dart';
import 'package:examples/stories/components/keys_example.dart';
import 'package:examples/stories/components/look_at_example.dart';
import 'package:examples/stories/components/look_at_smooth_example.dart';
import 'package:examples/stories/components/priority_example.dart';
import 'package:examples/stories/components/spawn_component_example.dart';
import 'package:examples/stories/components/time_scale_example.dart';
import 'package:flame/game.dart';

void addComponentsStories(Dashbook dashbook) {
  dashbook.storiesOf('Components')
    ..add(
      'Composability',
      (_) => GameWidget(game: ComposabilityExample()),
      codeLink: baseLink('components/composability_example.dart'),
      info: ComposabilityExample.description,
    )
    ..add(
      'Priority',
      (_) => GameWidget(game: PriorityExample()),
      codeLink: baseLink('components/priority_example.dart'),
      info: PriorityExample.description,
    )
    ..add(
      'Debug',
      (_) => GameWidget(game: DebugExample()),
      codeLink: baseLink('components/debug_example.dart'),
      info: DebugExample.description,
    )
    ..add(
      'ClipComponent',
      (context) => GameWidget(game: ClipComponentExample()),
      codeLink: baseLink('components/clip_component_example.dart'),
      info: ClipComponentExample.description,
    )
    ..add(
      'Look At',
      (_) => GameWidget(game: LookAtExample()),
      codeLink: baseLink('components/look_at_example.dart'),
      info: LookAtExample.description,
    )
    ..add(
      'Look At Smooth',
      (_) => GameWidget(game: LookAtSmoothExample()),
      codeLink: baseLink('components/look_at_smooth_example.dart'),
      info: LookAtExample.description,
    )
    ..add(
      'Component Notifier',
      (_) => const ComponentsNotifierExampleWidget(),
      codeLink: baseLink('components/components_notifier_example.dart'),
      info: ComponentsNotifierExampleWidget.description,
    )
    ..add(
      'Component Notifier (with provider)',
      (_) => const ComponentsNotifierProviderExampleWidget(),
      codeLink:
          baseLink('components/components_notifier_provider_example.dart'),
      info: ComponentsNotifierProviderExampleWidget.description,
    )
    ..add(
      'Spawn Component',
      (_) => const GameWidget.controlled(
        gameFactory: SpawnComponentExample.new,
      ),
      codeLink: baseLink('components/spawn_component_example.dart'),
      info: SpawnComponentExample.description,
    )
    ..add(
      'Time Scale',
      (_) => const GameWidget.controlled(
        gameFactory: TimeScaleExample.new,
      ),
      codeLink: baseLink('components/time_scale_example.dart'),
      info: TimeScaleExample.description,
    )
    ..add(
      'Component Keys',
      (_) => const KeysExampleWidget(),
      codeLink: baseLink('components/keys_example.dart'),
      info: KeysExampleWidget.description,
    )
    ..add(
      'HasVisibility',
      (_) => GameWidget(game: HasVisibilityExample()),
      codeLink: baseLink('components/has_visibility_example.dart'),
      info: HasVisibilityExample.description,
    );
}
