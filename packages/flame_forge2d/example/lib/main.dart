import 'dart:html';

import 'package:flame/game.dart';
import 'package:flame_forge2d_example/joints/constant_volume_joint.dart';
import 'package:flutter/widgets.dart';

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  final routes = <String, Game Function()>{
    'constant_volume_joint': ConstantVolumeJointExample.new,
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
