import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/components/clip_component_example.dart';
import 'package:examples/stories/components/component_pool_example.dart';
import 'package:examples/stories/components/components_notifier_example.dart';
import 'package:examples/stories/components/components_notifier_provider_example.dart';
import 'package:examples/stories/components/composability_example.dart';
import 'package:examples/stories/components/debug_example.dart';
import 'package:examples/stories/components/has_visibility_example.dart';
import 'package:examples/stories/components/icon_component_example.dart';
import 'package:examples/stories/components/keys_example.dart';
import 'package:examples/stories/components/look_at_example.dart';
import 'package:examples/stories/components/look_at_smooth_example.dart';
import 'package:examples/stories/components/priority_example.dart';
import 'package:examples/stories/components/skip_text_box_component_example.dart';
import 'package:examples/stories/components/spawn_component_example.dart';
import 'package:examples/stories/components/time_scale_example.dart';
import 'package:examples/stories/components/widget_component_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent componentsStories() {
  return WidgetbookComponent(
    name: 'Components',
    useCases: [
      ExampleUseCase(
        name: 'Composability',
        builder: (_) => GameWidget(game: ComposabilityExample()),
        codeLink: baseLink('components/composability_example.dart'),
        info: ComposabilityExample.description,
      ),
      ExampleUseCase(
        name: 'Priority',
        builder: (_) => GameWidget(game: PriorityExample()),
        codeLink: baseLink('components/priority_example.dart'),
        info: PriorityExample.description,
      ),
      ExampleUseCase(
        name: 'Debug',
        builder: (_) => GameWidget(game: DebugExample()),
        codeLink: baseLink('components/debug_example.dart'),
        info: DebugExample.description,
      ),
      ExampleUseCase(
        name: 'ClipComponent',
        builder: (context) => GameWidget(game: ClipComponentExample()),
        codeLink: baseLink('components/clip_component_example.dart'),
        info: ClipComponentExample.description,
      ),
      ExampleUseCase(
        name: 'Component Pool',
        builder: (_) => const GameWidget.managed(
          gameFactory: ComponentPoolExample.new,
        ),
        codeLink: baseLink('components/component_pool_example.dart'),
        info: ComponentPoolExample.description,
      ),
      ExampleUseCase(
        name: 'Look At',
        builder: (_) => GameWidget(game: LookAtExample()),
        codeLink: baseLink('components/look_at_example.dart'),
        info: LookAtExample.description,
      ),
      ExampleUseCase(
        name: 'Look At Smooth',
        builder: (_) => GameWidget(game: LookAtSmoothExample()),
        codeLink: baseLink('components/look_at_smooth_example.dart'),
        info: LookAtExample.description,
      ),
      ExampleUseCase(
        name: 'Component Notifier',
        builder: (_) => const ComponentsNotifierExampleWidget(),
        codeLink: baseLink('components/components_notifier_example.dart'),
        info: ComponentsNotifierExampleWidget.description,
      ),
      ExampleUseCase(
        name: 'Component Notifier (with provider)',
        builder: (_) => const ComponentsNotifierProviderExampleWidget(),
        codeLink: baseLink(
          'components/components_notifier_provider_example.dart',
        ),
        info: ComponentsNotifierProviderExampleWidget.description,
      ),
      ExampleUseCase(
        name: 'Spawn Component',
        builder: (_) => const GameWidget.managed(
          gameFactory: SpawnComponentExample.new,
        ),
        codeLink: baseLink('components/spawn_component_example.dart'),
        info: SpawnComponentExample.description,
      ),
      ExampleUseCase(
        name: 'Time Scale',
        builder: (_) => const GameWidget.managed(
          gameFactory: TimeScaleExample.new,
        ),
        codeLink: baseLink('components/time_scale_example.dart'),
        info: TimeScaleExample.description,
      ),
      ExampleUseCase(
        name: 'Component Keys',
        builder: (_) => const KeysExampleWidget(),
        codeLink: baseLink('components/keys_example.dart'),
        info: KeysExampleWidget.description,
      ),
      ExampleUseCase(
        name: 'Icon Component',
        builder: (_) => GameWidget(game: IconComponentExample()),
        codeLink: baseLink('components/icon_component_example.dart'),
        info: IconComponentExample.description,
      ),
      ExampleUseCase(
        name: 'HasVisibility',
        builder: (_) => GameWidget(game: HasVisibilityExample()),
        codeLink: baseLink('components/has_visibility_example.dart'),
        info: HasVisibilityExample.description,
      ),
      ExampleUseCase(
        name: 'Skip TextBoxComponent',
        builder: (_) => GameWidget(game: SkipTextBoxComponentExample()),
        codeLink: baseLink('components/skip_text_box_component_example.dart'),
        info: SkipTextBoxComponentExample.description,
      ),
      ExampleUseCase(
        name: 'Widget Component',
        builder: (_) => const GameWidget.managed(
          gameFactory: WidgetComponentExample.new,
        ),
        codeLink: baseLink('components/widget_component_example.dart'),
        info: WidgetComponentExample.description,
      ),
    ],
  );
}
