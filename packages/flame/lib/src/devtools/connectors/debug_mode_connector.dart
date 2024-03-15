import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [DebugModeConnector] is responsible for reporting and setting the
/// `debugMode` of the game from the devtools extension.
class DebugModeConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the current `debugMode`.
    registerExtension(
      'ext.flame_devtools.getDebugMode',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'debug_mode': game.debugMode,
          }),
        );
      },
    );

    // Set the `debugMode` for all components in the tree.
    registerExtension(
      'ext.flame_devtools.setDebugMode',
      (method, parameters) async {
        final debugMode = bool.parse(parameters['debug_mode'] ?? 'false');
        _setDebugMode(debugMode);
        return ServiceExtensionResponse.result(
          json.encode({
            'debug_mode': debugMode,
          }),
        );
      },
    );

    // Set the `debugMode` for one component in the tree.
    registerExtension(
      'ext.flame_devtools.setDebugModeSingle',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final debugMode = bool.parse(parameters['debug_mode'] ?? 'false');
        _setDebugMode(debugMode, id: id);
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': debugMode,
          }),
        );
      },
    );

    // Get the `debugMode` for one component in the tree.
    registerExtension(
      'ext.flame_devtools.getDebugModeSingle',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'debug_mode': id != null ? _getDebugMode(id) : null,
          }),
        );
      },
    );
  }

  bool _getDebugMode(int id) {
    var debugMode = false;
    game.propagateToChildren<Component>(
      (c) {
        if (c.hashCode != id) {
          debugMode = c.debugMode;
          return false;
        }
        return true;
      },
      includeSelf: true,
    );
    return debugMode;
  }

  void _setDebugMode(bool debugMode, {int? id}) {
    game.propagateToChildren<Component>(
      (c) {
        if (id != null && c.hashCode != id) {
          c.debugMode = debugMode;
          return false;
        }
        c.debugMode = debugMode;
        return true;
      },
      includeSelf: true,
    );
  }
}
