import 'package:dashbook/dashbook.dart';
import 'package:examples/stories/animations/animations.dart';
import 'package:examples/stories/bridge_libraries/audio/audio.dart';
import 'package:examples/stories/bridge_libraries/flame_isolate/isolate.dart';
import 'package:examples/stories/bridge_libraries/flame_lottie/lottie.dart';
import 'package:examples/stories/bridge_libraries/forge2d/flame_forge2d.dart';
import 'package:examples/stories/camera_and_viewport/camera_and_viewport.dart';
import 'package:examples/stories/collision_detection/collision_detection.dart';
import 'package:examples/stories/components/components.dart';
import 'package:examples/stories/effects/effects.dart';
import 'package:examples/stories/experimental/experimental.dart';
import 'package:examples/stories/games/games.dart';
import 'package:examples/stories/input/input.dart';
import 'package:examples/stories/parallax/parallax.dart';
import 'package:examples/stories/rendering/rendering.dart';
import 'package:examples/stories/sprites/sprites.dart';
import 'package:examples/stories/svg/svg.dart';
import 'package:examples/stories/system/system.dart';
import 'package:examples/stories/tiled/tiled.dart';
import 'package:examples/stories/utils/utils.dart';
import 'package:examples/stories/widgets/widgets.dart';
import 'package:flutter/material.dart';

void main() {
  final dashbook = Dashbook(
    title: 'Flame Examples',
    theme: ThemeData.dark(),
  );

  // Some small sample games
  addGameStories(dashbook);

  // Feature examples
  addAudioStories(dashbook);
  addAnimationStories(dashbook);
  addCameraAndViewportStories(dashbook);
  addCollisionDetectionStories(dashbook);
  addComponentsStories(dashbook);
  addEffectsStories(dashbook);
  addExperimentalStories(dashbook);
  addInputStories(dashbook);
  addParallaxStories(dashbook);
  addRenderingStories(dashbook);
  addTiledStories(dashbook);
  addSpritesStories(dashbook);
  addSvgStories(dashbook);
  addSystemStories(dashbook);
  addUtilsStories(dashbook);
  addWidgetsStories(dashbook);

  // Bridge package examples
  addForge2DStories(dashbook);
  addFlameIsolateExample(dashbook);
  addFlameLottieExample(dashbook);

  runApp(dashbook);
}
