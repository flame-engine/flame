import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:flutter/foundation.dart';

/// The [DebugModeConnector] is responsible for reporting and setting the
/// `debugMode` of the game from the devtools extension.
class DebugModeConnector extends DevToolsConnector {
  var _debugModeNotifier = ValueNotifier<bool>(false);

  @override
  void init() {
    // Get the current `debugMode`.
    registerExtension(
      'ext.flame_devtools.getDebugMode',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'debug_mode': _debugModeNotifier.value,
          }),
        );
      },
    );

    // Set the `debugMode` for all components in the tree.
    registerExtension(
      'ext.flame_devtools.setDebugMode',
      (method, parameters) async {
        final debugMode = bool.parse(parameters['debug_mode'] ?? 'false');
        _debugModeNotifier.value = debugMode;
        return ServiceExtensionResponse.result(
          json.encode({
            'debug_mode': debugMode,
          }),
        );
      },
    );
  }

  @override
  void initGame(FlameGame game) {
    super.initGame(game);
    _debugModeNotifier = ValueNotifier<bool>(game.debugMode);
    _debugModeNotifier.addListener(() {
      final newDebugMode = _debugModeNotifier.value;
      game.propagateToChildren<Component>(
        (c) {
          c.debugMode = newDebugMode;
          return true;
        },
        includeSelf: true,
      );
    });
  }

  @override
  void disposeGame() {
    _debugModeNotifier.dispose();
  }
}
