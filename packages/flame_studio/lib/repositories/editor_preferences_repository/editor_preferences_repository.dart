import 'package:flame_studio/clients/clients.dart';
import 'package:flame_studio/repositories/editor_preferences_repository/models/models.dart';

/// {@template editor_preferences_repository}
/// Keeps the preferences of the editor, which belong to the app rather than
/// to a project, such as the zoom of the preview of each component.
/// {@endtemplate}
class EditorPreferencesRepository({
  required final KeyValueStorageClient _storage,
}) {
  /// {@macro editor_preferences_repository}
  this;

  /// The zoom of a component whose zoom was never changed.
  static const defaultZoom = 1.0;

  /// The smallest zoom.
  static const double minZoom = ZoomLevels.min;

  /// The largest zoom.
  static const double maxZoom = ZoomLevels.max;

  /// Storage key under which the zoom of the component named
  /// [componentName] of the project at [projectPath] is persisted.
  static String componentZoomKey(String projectPath, String componentName) =>
      'component_zoom:$projectPath:$componentName';

  /// Returns the zoom of the preview of the component named [componentName]
  /// of the project at [projectPath], between [minZoom] and [maxZoom].
  ///
  /// Returns [defaultZoom] if nothing was stored or the stored value is
  /// unreadable.
  Future<double> getComponentZoom({
    required String projectPath,
    required String componentName,
  }) async {
    final raw = await _storage.read(
      componentZoomKey(projectPath, componentName),
    );
    final zoom = raw == null ? null : double.tryParse(raw);
    if (zoom == null || !zoom.isFinite) {
      return defaultZoom;
    }
    return zoom.clamp(minZoom, maxZoom);
  }

  /// Stores [zoom], clamped between [minZoom] and [maxZoom], as the zoom of
  /// the preview of the component named [componentName] of the project at
  /// [projectPath].
  Future<void> setComponentZoom({
    required String projectPath,
    required String componentName,
    required double zoom,
  }) {
    return _storage.write(
      componentZoomKey(projectPath, componentName),
      zoom.clamp(minZoom, maxZoom).toString(),
    );
  }
}
