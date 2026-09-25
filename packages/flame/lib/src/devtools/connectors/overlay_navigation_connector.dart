import 'dart:convert';
import 'dart:developer';

import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [OverlayNavigationConnector] is responsible of getting the names of all
/// registered overlays, navigating to the overlay with the given name, and
/// showing or hiding single overlays.
class OverlayNavigationConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the names of all registered overlays, and of the active ones.
    registerExtension(
      'ext.flame_devtools.getOverlays',
      (method, parameters) async {
        return ServiceExtensionResponse.result(
          json.encode({
            'overlays': game.overlays.registeredOverlays,
            'active': game.overlays.activeOverlays,
          }),
        );
      },
    );

    // Navigate to the overlay with the given name
    registerExtension(
      'ext.flame_devtools.navigateToOverlay',
      (method, parameters) async {
        final overlayName = parameters['overlay'];
        final error = _validateOverlay(overlayName);
        if (error != null) {
          return error;
        }

        game.overlays.clear();
        game.overlays.add(overlayName!);
        return ServiceExtensionResponse.result(json.encode({'success': true}));
      },
    );

    // Show or hide the overlay with the given name, without touching the
    // other active overlays.
    registerExtension(
      'ext.flame_devtools.setOverlay',
      (method, parameters) async {
        final overlayName = parameters['overlay'];
        final error = _validateOverlay(overlayName);
        if (error != null) {
          return error;
        }

        final active = bool.tryParse(parameters['active'] ?? '');
        if (active == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'The active parameter has to be true or false.',
          );
        }

        game.overlays.setActive(overlayName!, active: active);
        return ServiceExtensionResponse.result(
          json.encode({
            'overlay': overlayName,
            'active': active,
          }),
        );
      },
    );
  }

  ServiceExtensionResponse? _validateOverlay(String? overlayName) {
    if (overlayName == null) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.invalidParams,
        'Missing overlay parameter',
      );
    }
    if (!game.overlays.registeredOverlays.contains(overlayName)) {
      return ServiceExtensionResponse.error(
        ServiceExtensionResponse.invalidParams,
        'Unknown overlay: $overlayName',
      );
    }
    return null;
  }
}
