// Flare does not support Null-Safety, so we have no option here.
// ignore_for_file: import_of_legacy_library_into_null_safe

library flame_flare;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flare_dart/math/aabb.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/asset_provider.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

part 'src/flare_actor_component.dart';
part 'src/flare_animation.dart';
part 'src/flare_particle.dart';
