import 'dart:convert';
import 'dart:developer';

import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [OverlayNavConnector] is responsible of getting the names of all
/// registered overlays and navigating to the overlay with the given name.
class OverlayNavConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the names of all registered overlays
    registerExtension(
      'ext.flame_devtools.getOverlays',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'overlays': game.overlays.registeredOverlays,
          }),
        );
      },
    );

    // Navigate to the overlay with the given name
    registerExtension(
      'ext.flame_devtools.navigateToOverlay',
      (method, parameters) async {
        final overlayName = parameters['overlay'];

        if (overlayName == null) {
          return ServiceExtensionResponse.error(
            -32602,
            'Missing overlay parameter',
          );
        }

        if (!game.overlays.registeredOverlays.contains(overlayName)) {
          return ServiceExtensionResponse.error(
            -32602,
            'Unknown overlay: $overlayName',
          );
        }

        game.overlays.clear();
        game.overlays.add(overlayName);
        return ServiceExtensionResponse.result(json.encode({'success': true}));
      },
    );
  }
}
