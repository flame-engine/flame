import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:doc_flame_examples/anchor_by_effect.dart';
import 'package:doc_flame_examples/anchor_to_effect.dart';
import 'package:doc_flame_examples/collision_detection.dart';
import 'package:doc_flame_examples/decorator_blur.dart';
import 'package:doc_flame_examples/decorator_grayscale.dart';
import 'package:doc_flame_examples/decorator_rotate3d.dart';
import 'package:doc_flame_examples/decorator_shadow3d.dart';
import 'package:doc_flame_examples/decorator_tint.dart';
import 'package:doc_flame_examples/drag_events.dart';
import 'package:doc_flame_examples/rotate_by_effect.dart';
import 'package:doc_flame_examples/rotate_to_effect.dart';
import 'package:doc_flame_examples/router.dart';
import 'package:doc_flame_examples/scale_by_effect.dart';
import 'package:doc_flame_examples/scale_to_effect.dart';
import 'package:doc_flame_examples/sequence_effect.dart';
import 'package:doc_flame_examples/tap_events.dart';
import 'package:doc_flame_examples/value_route.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  final routes = <String, Game Function()>{
    'anchor_by_effect': AnchorByEffectGame.new,
    'anchor_to_effect': AnchorToEffectGame.new,
    'collision_detection': CollisionDetectionGame.new,
    'decorator_blur': DecoratorBlurGame.new,
    'decorator_grayscale': DecoratorGrayscaleGame.new,
    'decorator_rotate3d': DecoratorRotate3DGame.new,
    'decorator_shadow3d': DecoratorShadowGame.new,
    'decorator_tint': DecoratorTintGame.new,
    'drag_events': DragEventsGame.new,
    'rotate_by_effect': RotateByEffectGame.new,
    'rotate_to_effect': RotateToEffectGame.new,
    'router': RouterGame.new,
    'scale_by_effect': ScaleByEffectGame.new,
    'scale_to_effect': ScaleToEffectGame.new,
    'sequence_effect': SequenceEffectGame.new,
    'tap_events': TapEventsGame.new,
    'value_route': ValueRouteExample.new,
  };
  final game = routes[page]?.call();
  if (game != null) {
    runApp(GameWidget(game: game));
  } else {
    runApp(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Error: unknown page name "$page"'),
      ),
    );
  }
}
