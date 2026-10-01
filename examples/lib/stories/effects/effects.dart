import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/effects/color_effect_example.dart';
import 'package:examples/stories/effects/combined_effect_example.dart';
import 'package:examples/stories/effects/dual_effect_removal_example.dart';
import 'package:examples/stories/effects/effect_controllers_example.dart';
import 'package:examples/stories/effects/function_effect_example.dart';
import 'package:examples/stories/effects/hue_effect_example.dart';
import 'package:examples/stories/effects/move_effect_example.dart';
import 'package:examples/stories/effects/opacity_effect_example.dart';
import 'package:examples/stories/effects/remove_effect_example.dart';
import 'package:examples/stories/effects/rotate_around_effect_example.dart';
import 'package:examples/stories/effects/rotate_effect_example.dart';
import 'package:examples/stories/effects/scale_effect_example.dart';
import 'package:examples/stories/effects/sequence_effect_example.dart';
import 'package:examples/stories/effects/size_effect_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent effectsStories() {
  return WidgetbookComponent(
    name: 'Effects',
    useCases: [
      ExampleUseCase(
        name: 'Move Effect',
        builder: (_) => GameWidget(game: MoveEffectExample()),
        codeLink: baseLink('effects/move_effect_example.dart'),
        info: MoveEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Dual Effect Removal',
        builder: (_) => GameWidget(game: DualEffectRemovalExample()),
        codeLink: baseLink('effects/dual_effect_removal_example.dart'),
        info: DualEffectRemovalExample.description,
      ),
      ExampleUseCase(
        name: 'Rotate Effect',
        builder: (_) => GameWidget(game: RotateEffectExample()),
        codeLink: baseLink('effects/rotate_effect_example.dart'),
        info: RotateEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Rotate Around Effect',
        builder: (_) => GameWidget(game: RotateAroundEffectExample()),
        codeLink: baseLink('effects/rotate_around_effect_example.dart'),
        info: RotateAroundEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Size Effect',
        builder: (_) => GameWidget(game: SizeEffectExample()),
        codeLink: baseLink('effects/size_effect_example.dart'),
        info: SizeEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Scale Effect',
        builder: (_) => GameWidget(game: ScaleEffectExample()),
        codeLink: baseLink('effects/scale_effect_example.dart'),
        info: ScaleEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Opacity Effect',
        builder: (_) => GameWidget(game: OpacityEffectExample()),
        codeLink: baseLink('effects/opacity_effect_example.dart'),
        info: OpacityEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Hue Effect',
        builder: (_) => GameWidget(game: HueEffectExample()),
        codeLink: baseLink('effects/hue_effect_example.dart'),
        info: HueEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Color Effect',
        builder: (_) => GameWidget(game: ColorEffectExample()),
        codeLink: baseLink('effects/color_effect_example.dart'),
        info: ColorEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Sequence Effect',
        builder: (_) => GameWidget(game: SequenceEffectExample()),
        codeLink: baseLink('effects/sequence_effect_example.dart'),
        info: SequenceEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Combined Effect',
        builder: (_) => GameWidget(game: CombinedEffectExample()),
        codeLink: baseLink('effects/combined_effect_example.dart'),
        info: CombinedEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Remove Effect',
        builder: (_) => GameWidget(game: RemoveEffectExample()),
        codeLink: baseLink('effects/remove_effect_example.dart'),
        info: RemoveEffectExample.description,
      ),
      ExampleUseCase(
        name: 'Function Effect',
        builder: (_) => GameWidget(game: FunctionEffectExample()),
        codeLink: baseLink('effects/function_effect_example.dart'),
        info: FunctionEffectExample.description,
      ),
      ExampleUseCase(
        name: 'EffectControllers',
        builder: (_) => GameWidget(game: EffectControllersExample()),
        codeLink: baseLink('effects/effect_controllers_example.dart'),
        info: EffectControllersExample.description,
      ),
    ],
  );
}
