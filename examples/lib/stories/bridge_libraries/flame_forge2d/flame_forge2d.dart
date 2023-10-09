import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/animated_body_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/blob_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/camera_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/composition_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/contact_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/domino_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/drag_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/constant_volume_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/distance_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/friction_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/gear_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/motor_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/mouse_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/prismatic_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/pulley_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/revolute_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/rope_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/weld_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/raycast_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/revolute_joint_with_motor_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/sprite_body_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/tap_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/widget_example.dart';
import 'package:flame/game.dart';

String link(String example) =>
    baseLink('bridge_libraries/flame_forge2d/$example');

void addForge2DStories(Dashbook dashbook) {
  dashbook.storiesOf('flame_forge2d')
    ..add(
      'Blob example',
      (DashbookContext ctx) => GameWidget(game: BlobExample()),
      codeLink: link('blob_example.dart'),
      info: BlobExample.description,
    )
    ..add(
      'Composition example',
      (DashbookContext ctx) => GameWidget(game: CompositionExample()),
      codeLink: link('composition_example.dart'),
      info: CompositionExample.description,
    )
    ..add(
      'Domino example',
      (DashbookContext ctx) => GameWidget(game: DominoExample()),
      codeLink: link('domino_example.dart'),
      info: DominoExample.description,
    )
    ..add(
      'Contact Callbacks',
      (DashbookContext ctx) => GameWidget(game: ContactCallbacksExample()),
      codeLink: link('contact_callbacks_example.dart'),
      info: ContactCallbacksExample.description,
    )
    ..add(
      'RevoluteJoint with Motor',
      (DashbookContext ctx) =>
          GameWidget(game: RevoluteJointWithMotorExample()),
      codeLink: link('revolute_joint_with_motor_example.dart'),
      info: RevoluteJointExample.description,
    )
    ..add(
      'Sprite Bodies',
      (DashbookContext ctx) => GameWidget(game: SpriteBodyExample()),
      codeLink: link('sprite_body_example.dart'),
      info: SpriteBodyExample.description,
    )
    ..add(
      'Animated Bodies',
      (DashbookContext ctx) => GameWidget(game: AnimatedBodyExample()),
      codeLink: link('animated_body_example.dart'),
      info: AnimatedBodyExample.description,
    )
    ..add(
      'Tappable Body',
      (DashbookContext ctx) => GameWidget(game: TapCallbacksExample()),
      codeLink: link('tap_callbacks_example.dart'),
      info: TapCallbacksExample.description,
    )
    ..add(
      'Draggable Body',
      (DashbookContext ctx) => GameWidget(game: DragCallbacksExample()),
      codeLink: link('drag_callbacks_example.dart'),
      info: DragCallbacksExample.description,
    )
    ..add(
      'Camera',
      (DashbookContext ctx) => GameWidget(game: CameraExample()),
      codeLink: link('camera_example.dart'),
      info: CameraExample.description,
    )
    ..add(
      'Raycasting',
      (DashbookContext ctx) => GameWidget(game: RaycastExample()),
      codeLink: link('raycast_example.dart'),
      info: RaycastExample.description,
    )
    ..add(
      'Widgets',
      (DashbookContext ctx) => const BodyWidgetExample(),
      codeLink: link('widget_example.dart'),
      info: WidgetExample.description,
    );
  addJointsStories(dashbook);
}

void addJointsStories(Dashbook dashbook) {
  dashbook
      .storiesOf('flame_forge2d/joints')
      .add(
        'ConstantVolumeJoint',
        (DashbookContext ctx) => GameWidget(game: ConstantVolumeJointExample()),
        codeLink: link('joints/constant_volume_joint.dart'),
        info: ConstantVolumeJointExample.description,
      )
      .add(
        'DistanceJoint',
        (DashbookContext ctx) => GameWidget(game: DistanceJointExample()),
        codeLink: link('joints/distance_joint.dart'),
        info: DistanceJointExample.description,
      )
      .add(
        'FrictionJoint',
        (DashbookContext ctx) => GameWidget(game: FrictionJointExample()),
        codeLink: link('joints/friction_joint.dart'),
        info: FrictionJointExample.description,
      )
      .add(
        'GearJoint',
        (DashbookContext ctx) => GameWidget(game: GearJointExample()),
        codeLink: link('joints/gear_joint.dart'),
        info: GearJointExample.description,
      )
      .add(
        'MotorJoint',
        (DashbookContext ctx) => GameWidget(game: MotorJointExample()),
        codeLink: link('joints/motor_joint.dart'),
        info: MotorJointExample.description,
      )
      .add(
        'MouseJoint',
        (DashbookContext ctx) => GameWidget(game: MouseJointExample()),
        codeLink: link('joints/mouse_joint.dart'),
        info: MouseJointExample.description,
      )
      .add(
        'PrismaticJoint',
        (DashbookContext ctx) => GameWidget(game: PrismaticJointExample()),
        codeLink: link('joints/prismatic_joint.dart'),
        info: PrismaticJointExample.description,
      )
      .add(
        'PulleyJoint',
        (DashbookContext ctx) => GameWidget(game: PulleyJointExample()),
        codeLink: link('joints/pulley_joint.dart'),
        info: PulleyJointExample.description,
      )
      .add(
        'RevoluteJoint',
        (DashbookContext ctx) => GameWidget(game: RevoluteJointExample()),
        codeLink: link('joints/revolute_joint.dart'),
        info: RevoluteJointExample.description,
      )
      .add(
        'RopeJoint',
        (DashbookContext ctx) => GameWidget(game: RopeJointExample()),
        codeLink: link('joints/rope_joint.dart'),
        info: RopeJointExample.description,
      )
      .add(
        'WeldJoint',
        (DashbookContext ctx) => GameWidget(game: WeldJointExample()),
        codeLink: link('joints/weld_joint.dart'),
        info: WeldJointExample.description,
      );
}
