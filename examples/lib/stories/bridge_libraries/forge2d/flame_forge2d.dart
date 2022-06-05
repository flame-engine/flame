import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/bridge_libraries/forge2d/animated_body_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/blob_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/camera_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/composition_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/contact_callbacks_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/domino_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/draggable_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/joint_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/mouse_joint_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/raycast_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/revolute_joint_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/sprite_body_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/tappable_example.dart';
import 'package:examples/stories/bridge_libraries/forge2d/widget_example.dart';
import 'package:flame/game.dart';

String link(String example) => baseLink('bridge_libraries/forge2d/$example');

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
      'RevoluteJoint',
      (DashbookContext ctx) => GameWidget(game: RevoluteJointExample()),
      codeLink: link('revolute_joint_example.dart'),
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
      (DashbookContext ctx) => GameWidget(game: TappableExample()),
      codeLink: link('tappable_example.dart'),
      info: TappableExample.description,
    )
    ..add(
      'Draggable Body',
      (DashbookContext ctx) => GameWidget(game: DraggableExample()),
      codeLink: link('draggable_example.dart'),
      info: DraggableExample.description,
    )
    ..add(
      'Basic joint',
      (DashbookContext ctx) => GameWidget(game: JointExample()),
      codeLink: link('joint_example.dart'),
      info: JointExample.description,
    )
    ..add(
      'Mouse Joint',
      (DashbookContext ctx) => GameWidget(game: MouseJointExample()),
      codeLink: link('mouse_joint_example.dart'),
      info: MouseJointExample.description,
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
}
