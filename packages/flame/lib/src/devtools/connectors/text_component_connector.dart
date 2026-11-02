import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:meta/meta.dart';

/// The [TextComponentConnector] is responsible for changing the text of a
/// [TextComponent] from the devtools extension.
///
/// The text itself is reported with the other attributes of a component.
class TextComponentConnector() extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.setComponentText',
      (method, parameters) => setText(parameters),
    );
  }

  /// Sets the text of the [TextComponent] with the `id` in [parameters] to the
  /// `text` parameter, which can be empty but not missing.
  @visibleForTesting
  Future<ServiceExtensionResponse> setText(
    Map<String, String> parameters,
  ) async {
    final id = int.tryParse(parameters['id'] ?? '');
    final component = findComponent<TextComponent>(id);
    if (component == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.invalidParams,
        'No TextComponent found with id: $id',
      );
    }

    final text = parameters['text'];
    if (text == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.invalidParams,
        'The text parameter is required.',
      );
    }

    component.text = text;
    // A paused game neither updates nor repaints, so the cached image of a
    // text box is redrawn and the game is repainted here.
    if (component is TextBoxComponent) {
      await component.redraw();
    }
    if (game.isAttached) {
      game.renderBox.markNeedsPaint();
    }
    return ServiceExtensionResponse.result(
      json.encode({
        'id': id,
        'text': text,
      }),
    );
  }
}
