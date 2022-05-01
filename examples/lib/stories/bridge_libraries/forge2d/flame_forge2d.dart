import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../../commons/commons.dart';
import 'animated_body_example.dart';
import 'blob_example.dart';
import 'camera_example.dart';
import 'composition_example.dart';
import 'contact_callbacks_example.dart';
import 'domino_example.dart';
import 'draggable_example.dart';
import 'joint_example.dart';
import 'mouse_joint_example.dart';
import 'raycast_example.dart';
import 'revolute_joint_example.dart';
import 'sprite_body_example.dart';
import 'tappable_example.dart';
import 'widget_example.dart';

String link(String example) => baseLink('bride_libraries/$example');

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
