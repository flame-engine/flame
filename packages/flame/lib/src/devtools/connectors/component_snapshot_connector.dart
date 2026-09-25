import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [ComponentSnapshotConnector] is responsible for rendering a single
/// component, together with its children, to a PNG image that is sent to the
/// devtools extension.
///
/// The id of the component is its `hashCode`, which can be retrieved from the
/// `ext.flame_devtools.getComponentTree` service extension. The optional
/// `pixelRatio` parameter can be used to render the image in a higher (or
/// lower) resolution than the logical size of the component.
class ComponentSnapshotConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getComponentSnapshot',
      (method, parameters) async {
        final pixelRatio = double.tryParse(parameters['pixelRatio'] ?? '1');
        if (pixelRatio == null || !pixelRatio.isFinite || pixelRatio <= 0) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'pixelRatio has to be a positive number, '
            'got ${parameters['pixelRatio']}.',
          );
        }

        final id = int.tryParse(parameters['id'] ?? '');
        final component = findComponent<Component>(id);
        final snapshot = component == null
            ? ''
            : await encodePng(
                snapshotComponent(component, pixelRatio: pixelRatio),
              );

        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'snapshot': snapshot,
          }),
        );
      },
    );
  }

  /// Renders [component] and its children to an image, with the size of the
  /// component multiplied by [pixelRatio].
  ///
  /// For a [PositionComponent] the image covers the bounding rectangle of the
  /// component in its parent's coordinate space, so anchor, angle and scale are
  /// all taken into account.
  static Image snapshotComponent(
    Component component, {
    double pixelRatio = 1,
  }) {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)..scale(pixelRatio);

    // I am not sure how we could calculate the size of a component
    // that isn't a PositionComponent, so for now we will just use
    // an arbitrary size.
    var width = 100.0;
    var height = 100.0;

    if (component is PositionComponent) {
      final rect = component.toRect();
      width = rect.width;
      height = rect.height;
      canvas.translate(-rect.left, -rect.top);
    }

    component.renderTree(canvas);

    final picture = pictureRecorder.endRecording();
    final image = picture.toImageSync(
      max((width * pixelRatio).ceil(), 1),
      max((height * pixelRatio).ceil(), 1),
    );
    picture.dispose();
    return image;
  }
}
