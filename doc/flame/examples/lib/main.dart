import 'dart:html'; // ignore: avoid_web_libraries_in_flutter

import 'package:doc_flame_examples/anchor_by_effect.dart';
import 'package:doc_flame_examples/anchor_to_effect.dart';
import 'package:doc_flame_examples/collision_detection.dart';
import 'package:doc_flame_examples/color_effect.dart';
import 'package:doc_flame_examples/decorator_blur.dart';
import 'package:doc_flame_examples/decorator_grayscale.dart';
import 'package:doc_flame_examples/decorator_rotate3d.dart';
import 'package:doc_flame_examples/decorator_shadow3d.dart';
import 'package:doc_flame_examples/decorator_tint.dart';
import 'package:doc_flame_examples/drag_events.dart';
import 'package:doc_flame_examples/glow_effect.dart';
import 'package:doc_flame_examples/move_along_path_effect.dart';
import 'package:doc_flame_examples/move_by_effect.dart';
import 'package:doc_flame_examples/move_to_effect.dart';
import 'package:doc_flame_examples/opacity_by_effect.dart';
import 'package:doc_flame_examples/opacity_effect_with_target.dart';
import 'package:doc_flame_examples/opacity_to_effect.dart';
import 'package:doc_flame_examples/ray_cast.dart';
import 'package:doc_flame_examples/ray_trace.dart';
import 'package:doc_flame_examples/remove_effect.dart';
import 'package:doc_flame_examples/rive_example.dart';
import 'package:doc_flame_examples/rotate_by_effect.dart';
import 'package:doc_flame_examples/rotate_to_effect.dart';
import 'package:doc_flame_examples/router.dart';
import 'package:doc_flame_examples/scale_by_effect.dart';
import 'package:doc_flame_examples/scale_to_effect.dart';
import 'package:doc_flame_examples/sequence_effect.dart';
import 'package:doc_flame_examples/size_by_effect.dart';
import 'package:doc_flame_examples/size_to_effect.dart';
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
    'opacity_to_effect': OpacityToEffectGame.new,
    'opacity_effect_with_target': OpacityEffectWithTargetGame.new,
    'opacity_by_effect': OpacityByEffectGame.new,
    'move_along_path_effect': MoveAlongPathEffectGame.new,
    'move_by_effect': MoveByEffectGame.new,
    'move_to_effect': MoveToEffectGame.new,
    'rotate_by_effect': RotateByEffectGame.new,
    'rotate_to_effect': RotateToEffectGame.new,
    'router': RouterGame.new,
    'scale_by_effect': ScaleByEffectGame.new,
    'scale_to_effect': ScaleToEffectGame.new,
    'size_by_effect': SizeByEffectGame.new,
    'size_to_effect': SizeToEffectGame.new,
    'sequence_effect': SequenceEffectGame.new,
    'tap_events': TapEventsGame.new,
    'value_route': ValueRouteExample.new,
    'rive_example': RiveExampleGame.new,
    'ray_cast': RayCastExample.new,
    'ray_trace': RayTraceExample.new,
    'glow_effect': GlowEffectExample.new,
    'remove_effect': RemoveEffectGame.new,
    'color_effect': ColorEffectExample.new,
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
