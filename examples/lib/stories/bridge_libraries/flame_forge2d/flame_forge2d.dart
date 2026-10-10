import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/animated_body_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/camera_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/composition_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/contact_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/domino_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/drag_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/distance_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/filter_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/motor_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/mouse_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/prismatic_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/revolute_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/weld_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/wheel_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/raycast_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/revolute_joint_with_motor_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/sprite_body_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/tap_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/widget_example.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

String link(String example) =>
    baseLink('bridge_libraries/flame_forge2d/$example');

WidgetbookComponent forge2DStories() {
  return WidgetbookComponent(
    name: 'flame_forge2d',
    useCases: [
      ExampleUseCase(
        name: 'Composition example',
        builder: (_) => GameWidget(game: CompositionExample()),
        codeLink: link('composition_example.dart'),
        info: CompositionExample.description,
      ),
      ExampleUseCase(
        name: 'Domino example',
        builder: (_) => GameWidget(game: DominoExample()),
        codeLink: link('domino_example.dart'),
        info: DominoExample.description,
      ),
      ExampleUseCase(
        name: 'Contact Callbacks',
        builder: (_) => GameWidget(game: ContactCallbacksExample()),
        codeLink: link('contact_callbacks_example.dart'),
        info: ContactCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'RevoluteJoint with Motor',
        builder: (_) => GameWidget(game: RevoluteJointWithMotorExample()),
        codeLink: link('revolute_joint_with_motor_example.dart'),
        info: RevoluteJointWithMotorExample.description,
      ),
      ExampleUseCase(
        name: 'Sprite Bodies',
        builder: (context) => _SpriteBodyStory(
          showPieces: context.knobs.boolean(label: 'Show pieces'),
        ),
        codeLink: link('sprite_body_example.dart'),
        info: SpriteBodyExample.description,
      ),
      ExampleUseCase(
        name: 'Animated Bodies',
        builder: (_) => GameWidget(game: AnimatedBodyExample()),
        codeLink: link('animated_body_example.dart'),
        info: AnimatedBodyExample.description,
      ),
      ExampleUseCase(
        name: 'Tappable Body',
        builder: (_) => GameWidget(game: TapCallbacksExample()),
        codeLink: link('tap_callbacks_example.dart'),
        info: TapCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'Draggable Body',
        builder: (_) => GameWidget(game: DragCallbacksExample()),
        codeLink: link('drag_callbacks_example.dart'),
        info: DragCallbacksExample.description,
      ),
      ExampleUseCase(
        name: 'Camera',
        builder: (_) => GameWidget(game: CameraExample()),
        codeLink: link('camera_example.dart'),
        info: CameraExample.description,
      ),
      ExampleUseCase(
        name: 'Raycasting',
        builder: (_) => GameWidget(game: RaycastExample()),
        codeLink: link('raycast_example.dart'),
        info: RaycastExample.description,
      ),
      ExampleUseCase(
        name: 'Widgets',
        builder: (_) => const BodyWidgetExample(),
        codeLink: link('widget_example.dart'),
        info: WidgetExample.description,
      ),
    ],
  );
}

WidgetbookComponent jointsStories() {
  return WidgetbookComponent(
    name: 'flame_forge2d/joints',
    useCases: [
      ExampleUseCase(
        name: 'FilterJoint',
        builder: (_) => GameWidget(game: FilterJointExample()),
        codeLink: link('joints/filter_joint.dart'),
        info: FilterJointExample.description,
      ),
      ExampleUseCase(
        name: 'DistanceJoint',
        builder: (_) => GameWidget(game: DistanceJointExample()),
        codeLink: link('joints/distance_joint.dart'),
        info: DistanceJointExample.description,
      ),
      ExampleUseCase(
        name: 'MotorJoint',
        builder: (_) => GameWidget(game: MotorJointExample()),
        codeLink: link('joints/motor_joint.dart'),
        info: MotorJointExample.description,
      ),
      ExampleUseCase(
        name: 'MouseJoint',
        builder: (_) => GameWidget(game: MouseJointExample()),
        codeLink: link('joints/mouse_joint.dart'),
        info: MouseJointExample.description,
      ),
      ExampleUseCase(
        name: 'PrismaticJoint',
        builder: (_) => GameWidget(game: PrismaticJointExample()),
        codeLink: link('joints/prismatic_joint.dart'),
        info: PrismaticJointExample.description,
      ),
      ExampleUseCase(
        name: 'RevoluteJoint',
        builder: (_) => GameWidget(game: RevoluteJointExample()),
        codeLink: link('joints/revolute_joint.dart'),
        info: RevoluteJointExample.description,
      ),
      ExampleUseCase(
        name: 'WeldJoint',
        builder: (_) => GameWidget(game: WeldJointExample()),
        codeLink: link('joints/weld_joint.dart'),
        info: WeldJointExample.description,
      ),
      ExampleUseCase(
        name: 'WheelJoint',
        builder: (_) => GameWidget(game: WheelJointExample()),
        codeLink: link('joints/wheel_joint.dart'),
        info: WheelJointExample.description,
      ),
    ],
  );
}

/// Hosts a single [SpriteBodyExample] and applies the [showPieces] knob to it,
/// so that changing the knob doesn't restart the game.
class const _SpriteBodyStory({required final bool showPieces})
    extends StatefulWidget {
  @override
  State<_SpriteBodyStory> createState() => _SpriteBodyStoryState();
}

class _SpriteBodyStoryState() extends State<_SpriteBodyStory> {
  late final _game = SpriteBodyExample(showPieces: widget.showPieces);

  @override
  void didUpdateWidget(_SpriteBodyStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPieces != oldWidget.showPieces) {
      (_game.world as SpriteBodyWorld).showPieces = widget.showPieces;
    }
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}
