import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template zoom_controls}
/// Zoom out and zoom in buttons around the current [zoom], as a
/// percentage, which resets it to 100% when pressed.
///
/// A `null` callback disables its button, e.g. at the smallest or largest
/// zoom.
/// {@endtemplate}
class const ZoomControls({
  /// The current zoom, `1` being the actual size.
  required final double zoom,

  /// Called when the user zooms in.
  required final VoidCallback? onZoomIn,

  /// Called when the user zooms out.
  required final VoidCallback? onZoomOut,

  /// Called when the user resets the zoom to 100%.
  required final VoidCallback? onReset,
  super.key,
}) extends StatelessWidget {
  /// {@macro zoom_controls}
  this;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Zoom out',
          iconSize: 20,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.zoom_out),
          onPressed: onZoomOut,
        ),
        Tooltip(
          message: 'Reset zoom',
          child: TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(56, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: onReset,
            child: Text('${(zoom * 100).round()}%'),
          ),
        ),
        IconButton(
          tooltip: 'Zoom in',
          iconSize: 20,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.zoom_in),
          onPressed: onZoomIn,
        ),
      ],
    );
  }
}

/// The zoom keyboard shortcuts, for a `CallbackShortcuts`: Cmd/Ctrl + `=`
/// (or `+`) zooms in, Cmd/Ctrl + `-` zooms out and Cmd/Ctrl + `0` resets
/// the zoom.
Map<ShortcutActivator, VoidCallback> zoomShortcuts({
  required VoidCallback onZoomIn,
  required VoidCallback onZoomOut,
  required VoidCallback onReset,
}) {
  return {
    for (final key in [
      LogicalKeyboardKey.equal,
      LogicalKeyboardKey.add,
      LogicalKeyboardKey.numpadAdd,
    ]) ...{
      SingleActivator(key, meta: true): onZoomIn,
      SingleActivator(key, control: true): onZoomIn,
      // `+` is Shift+= on most keyboards.
      SingleActivator(key, meta: true, shift: true): onZoomIn,
      SingleActivator(key, control: true, shift: true): onZoomIn,
    },
    for (final key in [
      LogicalKeyboardKey.minus,
      LogicalKeyboardKey.numpadSubtract,
    ]) ...{
      SingleActivator(key, meta: true): onZoomOut,
      SingleActivator(key, control: true): onZoomOut,
    },
    for (final key in [
      LogicalKeyboardKey.digit0,
      LogicalKeyboardKey.numpad0,
    ]) ...{
      SingleActivator(key, meta: true): onReset,
      SingleActivator(key, control: true): onReset,
    },
  };
}
