import 'dart:convert';
import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flame/src/devtools_helpers/dev_tools_connector.dart';
import 'package:flutter/foundation.dart';

/// The [GameLoopConnector] is responsible for reporting and setting the
/// pause/running state of the game and stepping the game forwards or backwards
/// from the devtools extension.
class GameLoopConnector extends DevToolsConnector {
  var _pauseNotifier = ValueNotifier<bool>(true);

  @override
  void init() {
    // Get the current `debugMode`.
    registerExtension(
      'ext.flame_devtools.getPaused',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'paused': _pauseNotifier.value,
          }),
        );
      },
    );

    // Set whether the game should be paused or not.
    registerExtension(
      'ext.flame_devtools.setPaused',
      (method, parameters) async {
        final shouldPause = bool.parse(parameters['paused'] ?? 'false');
        _pauseNotifier.value = shouldPause;
        return ServiceExtensionResponse.result(
          json.encode({
            'paused': shouldPause,
          }),
        );
      },
    );

    // Set whether the game should be paused or not.
    registerExtension(
      'ext.flame_devtools.step',
      (method, parameters) async {
        final stepTime = double.parse(parameters['step_time'] ?? '0');
        game.stepEngine(stepTime: stepTime);
        return ServiceExtensionResponse.result(
          json.encode({
            'step_time': stepTime,
          }),
        );
      },
    );
  }

  @override
  void initGame(FlameGame game) {
    super.initGame(game);
    _pauseNotifier = ValueNotifier<bool>(game.paused);
    _pauseNotifier.addListener(() {
      final newPaused = _pauseNotifier.value;
      if (newPaused) {
        game.pauseEngine();
      } else {
        game.resumeEngine();
      }
    });
  }

  @override
  void disposeGame() {
    _pauseNotifier.dispose();
  }
}
