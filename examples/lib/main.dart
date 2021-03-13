import 'package:dashbook/dashbook.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'stories/animations/animations.dart';
import 'stories/components/components.dart';
import 'stories/controls/controls.dart';
import 'stories/effects/effects.dart';
import 'stories/parallax/parallax.dart';
import 'stories/rendering/rendering.dart';
import 'stories/sprites/sprites.dart';
import 'stories/tile_maps/tile_maps.dart';
import 'stories/utils/utils.dart';
import 'stories/widgets/widgets.dart';

void main() async {
  final dashbook = Dashbook(
    // title: 'Flame Example',
    theme: ThemeData.dark(),
  );

  addAnimationStories(dashbook);
  addComponentsStories(dashbook);
  addEffectsStories(dashbook);
  addTileMapStories(dashbook);
  addControlsStories(dashbook);
  addSpritesStories(dashbook);
  addRenderingStories(dashbook);
  addUtilsStories(dashbook);
  addParallaxStories(dashbook);

  await _setupWidgetsExample();
  addWidgetsStories(dashbook);

  runApp(dashbook);
}

Future<void> _setupWidgetsExample() async {
  // used for the widgets examples
  // note: you do *not* need to do this on your regular Flame games!
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.images.loadAll(
    ['nine-box.png', 'buttons.png', 'shield.png', 'bomb_ptero.png'],
  );
}
