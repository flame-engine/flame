import 'package:flame/game.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

import './game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}
