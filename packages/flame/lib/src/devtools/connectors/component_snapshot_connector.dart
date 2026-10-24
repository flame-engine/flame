import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/connectors/game_snapshot_connector.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:flame/src/devtools/snapshot_annotations.dart';

/// The [ComponentSnapshotConnector] is responsible for rendering a single
/// component, together with its children, to a PNG image that is sent to the
/// devtools extension.
///
/// The id of the component is its `hashCode`, which can be retrieved from the
/// `ext.flame_devtools.getComponentTree` service extension. The optional
/// `pixelRatio` parameter can be used to render the image in a higher (or
/// lower) resolution than the logical size of the component. See
/// [SnapshotOptions] for the parameters that annotate the image and limit its
/// size.
class ComponentSnapshotConnector() extends DevToolsConnector {
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
        final SnapshotOptions options;
        try {
          options = SnapshotOptions.parse(parameters);
        } on FormatException catch (error) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            error.message,
          );
        }

        final id = int.tryParse(parameters['id'] ?? '');
        final component = findComponent<Component>(id);
        if (component == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'No component with the id ${parameters['id']} was found.',
          );
        }

        final effectivePixelRatio = options.fitPixelRatio(
          pixelRatio,
          componentBounds(component).size,
        );
        final annotations = options.annotate
            ? annotateComponent(
                component,
                pixelRatio: effectivePixelRatio,
                filter: options.annotationFilter,
              )
            : const <SnapshotAnnotation>[];
        final image = snapshotComponent(
          component,
          pixelRatio: effectivePixelRatio,
          annotations: annotations,
        );
        final width = image.width;
        final height = image.height;
        final snapshot = await encodePng(image);
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'snapshot': snapshot,
            'width': width,
            'height': height,
            'pixelRatio': effectivePixelRatio,
            if (options.annotate)
              'annotations': [
                for (final annotation in annotations) annotation.toJson(),
              ],
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
  /// all taken into account. For a [World] the bounding rectangle of all its
  /// position components is used. The [annotations] are drawn on top of the
  /// component.
  static Image snapshotComponent(
    Component component, {
    double pixelRatio = 1,
    List<SnapshotAnnotation> annotations = const [],
  }) {
    final bounds = componentBounds(component);
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder)
      ..save()
      ..scale(pixelRatio)
      ..translate(-bounds.left, -bounds.top);

    if (component is World) {
      // A world is only rendered through a camera, so its children are
      // rendered directly instead.
      for (final child in component.children) {
        child.renderTree(canvas);
      }
    } else {
      component.renderTree(canvas);
    }
    canvas.restore();

    final size = GameSnapshotConnector.imageSize(
      bounds.width,
      bounds.height,
      pixelRatio,
    );
    SnapshotAnnotation.paint(canvas, annotations, size);

    final picture = pictureRecorder.endRecording();
    final image = picture.toImageSync(
      size.width.toInt(),
      size.height.toInt(),
    );
    picture.dispose();
    return image;
  }

  /// Finds where the visible position components among [component] and its
  /// descendants are in a snapshot taken with [snapshotComponent].
  static List<SnapshotAnnotation> annotateComponent(
    Component component, {
    double pixelRatio = 1,
    RegExp? filter,
  }) {
    final bounds = componentBounds(component);
    return SnapshotAnnotation.collect(
      component,
      space: component is PositionComponent ? component.parent! : component,
      imageSize: GameSnapshotConnector.imageSize(
        bounds.width,
        bounds.height,
        pixelRatio,
      ),
      origin: bounds.topLeft,
      pixelRatio: pixelRatio,
      filter: filter,
    );
  }

  /// The part of the coordinate space that a snapshot of [component] covers,
  /// which is in the coordinate space of the parent for a [PositionComponent].
  static Rect componentBounds(Component component) {
    // I am not sure how we could calculate the size of a component
    // that isn't a PositionComponent, so for now we will just use
    // an arbitrary size.
    return switch (component) {
          PositionComponent() => component.toRect(),
          World() => GameSnapshotConnector.worldBounds(component),
          _ => null,
        } ??
        const Rect.fromLTWH(0, 0, 100, 100);
  }
}
