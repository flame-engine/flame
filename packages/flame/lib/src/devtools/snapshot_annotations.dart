import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart'
    show TextDirection, TextPainter, TextSpan, TextStyle;

/// The options of the snapshot service extensions that annotate the image
/// and limit its size.
///
/// With `annotate` set to `true` the outline of every visible
/// [PositionComponent] is drawn on top of the image, labeled with its id and
/// type, and `annotationFilter` is a regular expression that is matched case
/// insensitively against the type to only annotate some components. The
/// `maxSize` is the maximum length of the longest side of the image in pixels,
/// which lowers the pixel ratio if needed.
class SnapshotOptions({
  /// Whether the visible components are annotated in the image.
  final bool annotate = false,

  /// Only the components whose type matches this are annotated, if given.
  final RegExp? annotationFilter,

  /// The maximum length, in pixels, of the longest side of the image.
  final int? maxSize,
}) {
  /// Parses the options from the parameters of a service extension.
  ///
  /// Throws a [FormatException] with a message that can be shown to the user
  /// if one of the options is invalid.
  factory SnapshotOptions.parse(Map<String, String> parameters) {
    final filter = parameters['annotationFilter'];
    RegExp? annotationFilter;
    if (filter != null) {
      try {
        annotationFilter = RegExp(filter, caseSensitive: false);
      } on FormatException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          FormatException(
            'annotationFilter is not a valid regular expression: '
            '${error.message}',
          ),
          stackTrace,
        );
      }
    }

    final maxSizeParameter = parameters['maxSize'];
    final maxSize = maxSizeParameter == null
        ? null
        : int.tryParse(maxSizeParameter);
    if (maxSizeParameter != null && (maxSize == null || maxSize <= 0)) {
      throw FormatException(
        'maxSize has to be a positive integer, got $maxSizeParameter.',
      );
    }

    return SnapshotOptions(
      annotate: parameters['annotate'] == 'true',
      annotationFilter: annotationFilter,
      maxSize: maxSize,
    );
  }

  /// The pixel ratio that an image of the logical [size] is rendered with, so
  /// that its longest side is at most [maxSize] pixels.
  ///
  /// This is [pixelRatio] if the image already fits.
  double fitPixelRatio(double pixelRatio, Size size) {
    final maxSize = this.maxSize;
    final longestSide = max(size.width, size.height);
    if (maxSize == null || longestSide * pixelRatio <= maxSize) {
      return pixelRatio;
    }
    // Slightly less than the exact ratio, so that rounding the size of the
    // image up never makes it larger than the maximum size.
    return maxSize / longestSide * (1 - 1e-9);
  }
}

/// A component that is marked in an annotated snapshot.
class SnapshotAnnotation(
  /// The id of the component, which is its `hashCode`.
  final int id,

  /// The type of the component.
  final String name,

  /// The four corners of the component, in the pixel coordinates of the
  /// image.
  final List<Offset> corners,
) {
  /// The axis aligned bounding box of the [corners].
  Rect get box {
    final xs = corners.map((corner) => corner.dx);
    final ys = corners.map((corner) => corner.dy);
    return Rect.fromLTRB(
      xs.reduce(min),
      ys.reduce(min),
      xs.reduce(max),
      ys.reduce(max),
    );
  }

  Map<String, Object> toJson() {
    final box = this.box;
    return {
      'id': id,
      'name': name,
      'box': [box.left, box.top, box.width, box.height],
    };
  }

  /// Finds the visible position components among [root] and its descendants,
  /// and where they are in a snapshot.
  ///
  /// The snapshot renders the coordinate space of the component [space], an
  /// ancestor of the components or [root] itself, with [origin] in the top
  /// left corner of the image, scaled by [pixelRatio], to an image of
  /// [imageSize] pixels. The transforms of all the position components in
  /// between are applied, and a world is seen through the camera that renders
  /// it. Components that are hidden, that have no area or that are outside of
  /// the image or the viewport are left out, and with a [filter] only the
  /// components whose type matches it are included.
  static List<SnapshotAnnotation> collect(
    Component root, {
    required Component space,
    required Size imageSize,
    Offset origin = Offset.zero,
    double pixelRatio = 1,
    RegExp? filter,
  }) {
    final imageRect = Offset.zero & imageSize;
    final annotations = <SnapshotAnnotation>[];
    final cameras = <World, CameraComponent?>{};

    Offset toImage(Vector2 point) => Offset(
      (point.x - origin.dx) * pixelRatio,
      (point.y - origin.dy) * pixelRatio,
    );

    for (final component in root.descendants(includeSelf: true)) {
      if (component is! PositionComponent ||
          _isHidden(component, root) ||
          (filter != null &&
              !filter.hasMatch(component.runtimeType.toString()))) {
        continue;
      }
      final size = component.size;
      final mapped = _mapToSpace(
        component,
        [Vector2.zero(), Vector2(size.x, 0), size.clone(), Vector2(0, size.y)],
        root,
        space,
        (world) => cameras.putIfAbsent(world, () => _cameraOf(world)),
      );
      if (mapped == null) {
        continue;
      }
      final annotation = SnapshotAnnotation(
        component.hashCode,
        component.runtimeType.toString(),
        mapped.points.map(toImage).toList(),
      );
      final box = annotation.box;
      final clip = mapped.clip;
      if (box.width <= 0 ||
          box.height <= 0 ||
          !box.overlaps(imageRect) ||
          (clip != null &&
              !box.overlaps(
                Rect.fromPoints(
                  toImage(Vector2(clip.left, clip.top)),
                  toImage(Vector2(clip.right, clip.bottom)),
                ),
              ))) {
        continue;
      }
      annotations.add(annotation);
    }
    return annotations;
  }

  /// Draws the outlines of the [annotations] and their labels on [canvas],
  /// which has to be in the pixel coordinates of an image of [imageSize].
  ///
  /// The labels are placed close to the top left corner of the outlines, where
  /// they don't overlap the labels that were already placed, if possible.
  static void paint(
    Canvas canvas,
    List<SnapshotAnnotation> annotations,
    Size imageSize,
  ) {
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF000000);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final (index, annotation) in annotations.indexed) {
      final path = Path()..addPolygon(annotation.corners, true);
      canvas
        ..drawPath(path, outlinePaint)
        ..drawPath(path, paint..color = _colors[index % _colors.length]);
    }

    final placed = <Rect>[];
    for (final (index, annotation) in annotations.indexed) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${annotation.id} ${_shortName(annotation.name)}',
          style: const TextStyle(color: Color(0xFF000000), fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelSize = Size(
        textPainter.width + _labelPadding * 2,
        textPainter.height + _labelPadding * 2,
      );
      final label = _placeLabel(annotation.box, labelSize, imageSize, placed);
      placed.add(label);
      canvas.drawRect(
        label,
        Paint()..color = _colors[index % _colors.length],
      );
      textPainter
        ..paint(canvas, label.topLeft.translate(_labelPadding, _labelPadding))
        ..dispose();
    }
  }

  static const _labelPadding = 2.0;
  static const _maxNameLength = 20;

  static const _colors = [
    Color(0xFFFFEB3B),
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
    Color(0xFF76FF03),
    Color(0xFFFF9100),
    Color(0xFFE040FB),
  ];

  static String _shortName(String name) {
    final withoutTypeArguments = name.split('<').first;
    return withoutTypeArguments.length <= _maxNameLength
        ? withoutTypeArguments
        : withoutTypeArguments.substring(0, _maxNameLength);
  }

  static Rect _placeLabel(
    Rect box,
    Size labelSize,
    Size imageSize,
    List<Rect> placed,
  ) {
    Rect clamp(Offset topLeft) {
      final left = topLeft.dx
          .clamp(0, max(imageSize.width - labelSize.width, 0))
          .toDouble();
      final top = topLeft.dy
          .clamp(0, max(imageSize.height - labelSize.height, 0))
          .toDouble();
      return Offset(left, top) & labelSize;
    }

    double overlap(Rect rect) {
      var area = 0.0;
      for (final other in placed) {
        final intersection = rect.intersect(other);
        if (intersection.width > 0 && intersection.height > 0) {
          area += intersection.width * intersection.height;
        }
      }
      return area;
    }

    final candidates = [
      clamp(box.topLeft),
      clamp(box.topLeft.translate(0, -labelSize.height)),
      clamp(box.bottomLeft),
      clamp(box.bottomLeft.translate(0, -labelSize.height)),
      clamp(box.topRight),
      clamp(box.topLeft.translate(-labelSize.width, 0)),
      for (var step = 1; step <= 10; step++)
        clamp(box.topLeft.translate(0, labelSize.height * step)),
    ];
    var best = candidates.first;
    var bestOverlap = double.infinity;
    for (final candidate in candidates) {
      final candidateOverlap = overlap(candidate);
      if (candidateOverlap == 0) {
        return candidate;
      }
      if (candidateOverlap < bestOverlap) {
        best = candidate;
        bestOverlap = candidateOverlap;
      }
    }
    return best;
  }

  static bool _isHidden(Component component, Component root) {
    for (final ancestor in component.ancestors(includeSelf: true)) {
      if (ancestor is HasVisibility && !ancestor.isVisible) {
        return true;
      }
      if (ancestor == root) {
        break;
      }
    }
    return false;
  }

  static CameraComponent? _cameraOf(World world) {
    final game = world.findGame();
    if (game == null || !world.isMounted) {
      return null;
    }
    if (game.camera.world == world) {
      return game.camera;
    }
    for (final camera in game.descendants().whereType<CameraComponent>()) {
      if (camera.world == world) {
        return camera;
      }
    }
    return null;
  }

  /// Maps [points] from the local coordinates of [component] to the
  /// coordinates of [space], in which the snapshot renders [root], together
  /// with the area of the viewport that the points are clipped to when they
  /// are seen through a camera.
  ///
  /// Returns null if the component isn't rendered in [space].
  static ({List<Vector2> points, Rect? clip})? _mapToSpace(
    Component component,
    List<Vector2> points,
    Component root,
    Component space,
    CameraComponent? Function(World world) cameraOf,
  ) {
    var current = component;
    var mapped = points;
    Rect? clip;
    while (current != space) {
      switch (current) {
        case PositionComponent():
          mapped = mapped.map(current.positionOf).toList();
        case Viewport():
          mapped = mapped.map(current.localToGlobal).toList();
          clip = _viewportRect(current);
        case Viewfinder():
          final camera = current.camera;
          mapped = mapped.map(camera.localToGlobal).toList();
          clip = _viewportRect(camera.viewport);
          current = camera;
          continue;
        case World():
          final camera = cameraOf(current);
          if (camera == null) {
            return null;
          }
          mapped = mapped.map(camera.localToGlobal).toList();
          clip = _viewportRect(camera.viewport);
          current = camera;
          continue;
      }
      final parent = current.parent;
      if (parent == null) {
        return null;
      }
      if (parent is CameraComponent &&
          current == parent.backdrop &&
          current != root) {
        mapped = mapped.map(parent.viewport.localToGlobal).toList();
        clip = _viewportRect(parent.viewport);
      }
      current = parent;
    }
    return (points: mapped, clip: clip);
  }

  static Rect _viewportRect(Viewport viewport) {
    final size = viewport.size;
    return Rect.fromLTWH(
      viewport.position.x - viewport.anchor.x * size.x,
      viewport.position.y - viewport.anchor.y * size.y,
      size.x,
      size.y,
    );
  }
}
