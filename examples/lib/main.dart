import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'stories/animations/animations.dart';
import 'stories/camera_and_viewport/camera_and_viewport.dart';
import 'stories/collision_detection/collision_detection.dart';
import 'stories/components/components.dart';
import 'stories/effects/effects.dart';
import 'stories/input/input.dart';
import 'stories/parallax/parallax.dart';
import 'stories/rendering/rendering.dart';
import 'stories/sprites/sprites.dart';
import 'stories/tile_maps/tile_maps.dart';
import 'stories/utils/utils.dart';
import 'stories/widgets/widgets.dart';

void main() async {
  final dashbook = Dashbook(
    title: 'Flame Examples',
    theme: ThemeData.dark(),
  );

  addAnimationStories(dashbook);
  addComponentsStories(dashbook);
  addCollisionDetectionStories(dashbook);
  addEffectsStories(dashbook);
  addTileMapStories(dashbook);
  addInputStories(dashbook);
  addSpritesStories(dashbook);
  addRenderingStories(dashbook);
  addUtilsStories(dashbook);
  addCameraAndViewportStories(dashbook);
  addParallaxStories(dashbook);
  addWidgetsStories(dashbook);

  runApp(dashbook);
}
