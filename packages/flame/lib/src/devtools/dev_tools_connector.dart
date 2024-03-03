import 'dart:developer';

import 'package:flame/debug.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

/// When a [DevToolsConnector] is initialized by the [DevToolsService] it will
/// call the [init] method the first time, where you should will register
/// service extensions which makes it possible for the devtools extension to
/// communicate with your interface. Then the [initGame] method will be called
/// every time a new game is set in the service.
abstract class DevToolsConnector {
  DevToolsConnector() {
    init();
  }

  late FlameGame game;

  /// In this method, you should register service extensions using
  /// [registerExtension] from dart:developer
  /// (see https://api.flutter.dev/flutter/dart-developer/registerExtension.html).
  void init();

  @mustCallSuper
  // ignore: use_setters_to_change_properties
  void initGame(FlameGame game) {
    this.game = game;
  }

  /// Here you can do clean-up before a new game is set in the connector.
  void disposeGame() {}
}
