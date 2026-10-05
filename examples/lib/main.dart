import 'package:examples/commons/example_app.dart';
import 'package:examples/platform/stub_provider.dart'
    if (dart.library.html) 'platform/web_provider.dart';
import 'package:examples/stories/animations/animations.dart';
import 'package:examples/stories/bridge_libraries/audio/audio.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/basic_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/flame_behavior_tree.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/race_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/robot_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/switch_tree_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/thief_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/tick_interval_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/traffic_example.dart';
import 'package:examples/stories/bridge_libraries/flame_behavior_tree/turret_example.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/flame_forge2d.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/distance_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/filter_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/motor_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/mouse_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/prismatic_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/revolute_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/weld_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_forge2d/joints/wheel_joint.dart';
import 'package:examples/stories/bridge_libraries/flame_isolate/isolate.dart';
import 'package:examples/stories/bridge_libraries/flame_jenny/jenny.dart';
import 'package:examples/stories/bridge_libraries/flame_lottie/lottie.dart';
import 'package:examples/stories/bridge_libraries/flame_spine/flame_spine.dart';
import 'package:examples/stories/camera_and_viewport/camera_and_viewport.dart';
import 'package:examples/stories/collision_detection/collision_detection.dart';
import 'package:examples/stories/components/components.dart';
import 'package:examples/stories/effects/effects.dart';
import 'package:examples/stories/experimental/experimental.dart';
import 'package:examples/stories/games/games.dart';
import 'package:examples/stories/image/image.dart';
import 'package:examples/stories/input/input.dart';
import 'package:examples/stories/layout/layout.dart';
import 'package:examples/stories/parallax/parallax.dart';
import 'package:examples/stories/rendering/decorators.dart';
import 'package:examples/stories/rendering/rendering.dart';
import 'package:examples/stories/router/router.dart';
import 'package:examples/stories/sprites/sprites.dart';
import 'package:examples/stories/structure/structure.dart';
import 'package:examples/stories/svg/svg.dart';
import 'package:examples/stories/system/system.dart';
import 'package:examples/stories/tiled/tiled.dart';
import 'package:examples/stories/utils/utils.dart';
import 'package:examples/stories/widgets/widgets.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  final page = PageProviderImpl().getPage();

  final routes = <String, FlameGame Function()>{
    'basic_example': BasicExample.new,
    'robot_example': RobotExample.new,
    'traffic_example': TrafficExample.new,
    'turret_example': TurretExample.new,
    'thief_example': ThiefExample.new,
    'race_example': RaceExample.new,
    'tick_interval_example': TickIntervalExample.new,
    'switch_tree_example': SwitchTreeExample.new,
    'distance_joint': DistanceJointExample.new,
    'motor_joint': MotorJointExample.new,
    'mouse_joint': MouseJointExample.new,
    'prismatic_joint': PrismaticJointExample.new,
    'revolute_joint': RevoluteJointExample.new,
    'weld_joint': WeldJointExample.new,
    'wheel_joint': WheelJointExample.new,
    'filter_joint': FilterJointExample.new,
  };
  final game = routes[page]?.call();
  if (game != null) {
    runApp(GameWidget(game: game));
  } else {
    runAsWidgetbook();
  }
}

void runAsWidgetbook() {
  runApp(
    Widgetbook(
      appBuilder: (_, child) => ExampleApp(child: child),
      addons: [ViewportAddon(Viewports.all)],
      header: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Image.asset('assets/images/flame.png', height: 28),
            const SizedBox(width: 12),
            const Text(
              'Flame Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      home: const ExampleApp(
        child: Center(
          child: Text('Select an example in the navigation to try it out.'),
        ),
      ),
      enableLeafComponents: false,
      directories: [
        // Some small sample games
        gameStories(),

        // Show some different ways of structuring games
        structureStories(),

        // Feature examples
        audioStories(),
        animationStories(),
        cameraAndViewportStories(),
        collisionDetectionStories(),
        componentsStories(),
        decoratorStories(),
        effectsStories(),
        experimentalStories(),
        inputStories(),
        layoutStories(),
        parallaxStories(),
        renderingStories(),
        routerStories(),
        tiledStories(),
        spritesStories(),
        svgStories(),
        systemStories(),
        utilsStories(),
        widgetsStories(),
        imageStories(),

        // Bridge package examples
        flameBehaviorTreeStories(),
        forge2DStories(),
        jointsStories(),
        flameIsolateStories(),
        flameJennyStories(),
        flameLottieStories(),
        flameSpineStories(),
      ],
    ),
  );
}
