import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

import '../../commons/commons.dart';
import 'advanced.dart';
import 'animation.dart';
import 'basic.dart';
import 'component.dart';
import 'no_fcs.dart';
import 'sandbox_layer.dart';
import 'small_parallax.dart';

void addParallaxStories(Dashbook dashbook) {
  dashbook.storiesOf('Parallax')
    ..add(
      'Basic',
      (_) => GameWidget(game: BasicParallaxGame()),
      codeLink: baseLink('parallax/basic.dart'),
      info: 'Shows the simplest way to use a fullscreen ParallaxComponent',
    )
    ..add(
      'Component',
      (_) => GameWidget(game: ComponentParallaxGame()),
      codeLink: baseLink('parallax/component.dart'),
      info: 'Shows how to do initiation and loading of assets from within an '
          'extended ParallaxComponent',
    )
    ..add(
      'Animation',
      (_) => GameWidget(game: AnimationParallaxGame()),
      codeLink: baseLink('parallax/animation.dart'),
      info: 'Shows how to use animations in a parallax',
    )
    ..add(
      'Non-fullscreen',
      (_) => GameWidget(game: SmallParallaxGame()),
      codeLink: baseLink('parallax/small_parallax.dart'),
      info: 'Shows how to create a smaller parallax in the center of the '
          'screen',
    )
    ..add(
      'No FCS',
      (_) => GameWidget(game: NoFCSParallaxGame()),
      codeLink: baseLink('parallax/no_fcs.dart'),
      info: "Shows how to use the parallax without Flame's component system",
    )
    ..add(
      'Advanced',
      (_) => GameWidget(game: AdvancedParallaxGame()),
      codeLink: baseLink('parallax/advanced.dart'),
      info: 'Shows how to create a parallax with different velocity deltas on '
          'each layer',
    )
    ..add(
      'Layer sandbox',
      (context) {
        return GameWidget(
          game: SandBoxLayerParallaxGame(
            planeSpeed: Vector2(
              context.numberProperty('plane x speed', 0),
              context.numberProperty('plane y speed', 0),
            ),
            planeRepeat: context.listProperty(
              'plane repeat strategy',
              ImageRepeat.noRepeat,
              ImageRepeat.values,
            ),
            planeFill: context.listProperty(
              'plane fill strategy',
              LayerFill.none,
              LayerFill.values,
            ),
            planeAlignment: context.listProperty(
              'plane alignment strategy',
              Alignment.center,
              [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.center,
                Alignment.topCenter,
                Alignment.centerLeft,
                Alignment.bottomLeft,
                Alignment.bottomRight,
                Alignment.bottomCenter,
              ],
            ),
          ),
        );
      },
      codeLink: baseLink('parallax/sandbox_layer.dart'),
      info: 'In this example, properties of a layer can be changed to preview '
          'the different combination of values',
    );
}
