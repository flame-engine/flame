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
      (_) => GameWidget(game: BasicParallaxExample()),
      codeLink: baseLink('parallax/basic.dart'),
      info: BasicParallaxExample.description,
    )
    ..add(
      'Component',
      (_) => GameWidget(game: ComponentParallaxExample()),
      codeLink: baseLink('parallax/component.dart'),
      info: ComponentParallaxExample.description,
    )
    ..add(
      'Animation',
      (_) => GameWidget(game: AnimationParallaxExample()),
      codeLink: baseLink('parallax/animation.dart'),
      info: AnimationParallaxExample.description,
    )
    ..add(
      'Non-fullscreen',
      (_) => GameWidget(game: SmallParallaxExample()),
      codeLink: baseLink('parallax/small_parallax.dart'),
      info: SmallParallaxExample.description,
    )
    ..add(
      'No FCS',
      (_) => GameWidget(game: NoFCSParallaxExample()),
      codeLink: baseLink('parallax/no_fcs.dart'),
      info: NoFCSParallaxExample.description,
    )
    ..add(
      'Advanced',
      (_) => GameWidget(game: AdvancedParallaxExample()),
      codeLink: baseLink('parallax/advanced.dart'),
      info: AdvancedParallaxExample.description,
    )
    ..add(
      'Layer sandbox',
      (context) {
        return GameWidget(
          game: SandboxLayerParallaxExample(
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
      info: SandboxLayerParallaxExample.description,
    );
}
