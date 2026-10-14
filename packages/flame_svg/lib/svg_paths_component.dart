import 'dart:math' show min;
import 'dart:ui' show Paint, PaintingStyle;

import 'package:flame/cache.dart' show AssetsCache;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// How an [SvgPathsComponent] creates its hitboxes.
enum SvgHitboxes() {
  /// A single [SvgPathsHitbox] for the whole SVG file, which is a child of
  /// the [SvgPathsComponent]. The paths that overlap or lie inside of each
  /// other count as a single solid, including for rays.
  single,

  /// A [PathHitbox] for each path, which is a child of its [PathComponent].
  perPath,
}

/// A position component representing a whole SVG file.
class SvgPathsComponent(
  this.svg, {
  this.hitboxes = SvgHitboxes.single,
  bool? renderHitboxes,
  bool? filter,
  double sampling = 1.0,
  double? tolerance,
  Vector2? size,
  super.position,
  super.scale,
  super.angle,
  super.anchor,
  super.priority,
  super.key,
}) extends PositionComponent {
  /// Create from the given [svg], with the given kind of [hitboxes].
  this
    : super(
        size: size ?? svg.bounds.size.toVector2(),
        children: [
          if (hitboxes == SvgHitboxes.perPath)
            ...createPathComponents(
              svg,
              size,
              renderHitboxes: renderHitboxes,
              filter: filter,
              sampling: sampling,
              tolerance: tolerance,
            ),
          if (hitboxes == SvgHitboxes.single && svg.length > 0)
            createSvgPathsHitbox(
              svg,
              size,
              renderHitboxes: renderHitboxes,
              filter: filter,
              sampling: sampling,
              tolerance: tolerance,
            ),
        ],
      );

  /// Load an [SvgPaths] object from the given [svgName], and create
  /// an [SvgPathsComponent] from it.
  ///
  /// The file is read from the [assetsPath] folder (see [assetPath]) via
  /// the [cache], within the given [package] if any, and its paths are
  /// optionally merged, see [SvgPaths.fromFile].
  static Future<SvgPathsComponent> load(
    String svgName, {
    String? assetsPath,
    AssetsCache? cache,
    String? package,
    bool merge = true,
    SvgHitboxes hitboxes = SvgHitboxes.single,
    bool? renderHitboxes,
    bool? filter,
    double sampling = 1.0,
    double? tolerance,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    ComponentKey? key,
  }) async {
    final svg = await SvgPaths.fromFile(
      assetPath(svgName, assetsPath),
      cache: cache,
      package: package,
      merge: merge,
    );
    return SvgPathsComponent(
      svg,
      hitboxes: hitboxes,
      renderHitboxes: renderHitboxes,
      filter: filter,
      sampling: sampling,
      tolerance: tolerance,
      position: position,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
      key: key,
    );
  }

  /// The path of the `.svg` file called [svgName] in the [assetsPath] folder,
  /// which is `assets/svgs/` by default, with or without a trailing slash.
  @visibleForTesting
  static String assetPath(String svgName, [String? assetsPath]) {
    final folder = assetsPath ?? 'assets/svgs/';
    return '${folder.endsWith('/') ? folder : '$folder/'}$svgName.svg';
  }

  /// The SVG file.
  final SvgPaths svg;

  /// How the hitboxes of the component are created.
  final SvgHitboxes hitboxes;

  /// With [SvgHitboxes.single] the paths are rendered by the component
  /// itself, since it has no [PathComponent]s.
  @override
  void render(Canvas canvas) {
    if (hitboxes == SvgHitboxes.single) {
      svg.render(canvas, size, area: svg.bounds);
    }
  }

  // Each hitbox gets its own paint, so that changing the paint of one does not
  // change the others.
  static Paint _whiteStroke() => Paint()
    ..color = const Color(0xffffffff)
    ..style = PaintingStyle.stroke;

  /// The scale that fits the [area] of the [svg], by default its bounds,
  /// within the [size] while keeping the aspect ratio, and the offset that
  /// centers it within the [size].
  static ({Rect full, double fit, Vector2 offset}) _layout(
    SvgPaths svg,
    Vector2? size, [
    Rect? area,
  ]) {
    final full = area ?? svg.bounds;
    final fullSize = full.size.toVector2();
    final target = size ?? fullSize;
    var fit = min(target.x / fullSize.x, target.y / fullSize.y);
    if (!fit.isFinite) {
      // There is nothing to fit, like in an empty SVG file.
      fit = 1;
    }
    return (full: full, fit: fit, offset: (target - fullSize * fit) / 2);
  }

  /// Creates a [PathComponent] for each path in the [svg].
  ///
  /// The paths are scaled to fit within the [size] of the component while
  /// keeping the aspect ratio, and are centered within it. This way the
  /// center of the component is the center of the SVG contents, which is what
  /// the component rotates and scales around.
  ///
  /// Each of the components gets a [PathHitbox], as with
  /// [SvgHitboxes.perPath].
  ///
  /// The [sampling] and [tolerance] of the polygons, see [PathComponent.new],
  /// are in the units of the [size], and not in those of the SVG file.
  static List<PathComponent> createPathComponents(
    SvgPaths svg,
    Vector2? size, {
    bool? renderHitboxes,
    bool? filter,
    double sampling = 1.0,
    double? tolerance,
  }) {
    final (:full, :fit, :offset) = _layout(svg, size);
    final (:pathSampling, :pathTolerance) = _toPathUnits(
      sampling,
      tolerance,
      fit,
    );
    final paths = <PathComponent>[];
    for (var svgIndex = 0; svgIndex < svg.length; ++svgIndex) {
      final vectorPath = svg.pathAt(svgIndex);
      final vectorPaint = vectorPath.paint;
      final path = vectorPath.path;
      // A PathComponent moves its path to the origin, so we restore its
      // position within the SVG.
      final position =
          (path.getBounds().topLeft - full.topLeft).toVector2() * fit + offset;

      // Filling a path closes its open contours implicitly, but the polygons
      // of a PathComponent only come from closed contours: without closing
      // them, the filled areas of open contours would be missing from the
      // hitbox. The rendering of the component only changes for a path that
      // is both filled and stroked, so that one keeps its original path.
      final closedPath = _hitboxPath(vectorPath);
      final hitbox = PathHitbox(
        path: closedPath,
        sampling: pathSampling,
        tolerance: pathTolerance,
        filter: filter ?? true,
      );
      if (renderHitboxes ?? false) {
        hitbox
          ..renderShape = true
          ..paint = _whiteStroke();
      }
      paths.add(
        PathComponent(
          path: vectorPaint.isStroked ? path : closedPath,
          position: position,
          scale: Vector2.all(fit),
          paint: vectorPaint.paint,
          paintLayers: vectorPaint.paintLayers,
          sampling: pathSampling,
          tolerance: pathTolerance,
          filter: filter ?? true,
          children: [hitbox],
        ),
      );
    }
    return paths;
  }

  /// Creates a single [SvgPathsHitbox] for all the paths in the [svg], placed
  /// like the components from [createPathComponents], which also describes
  /// the [sampling] and [tolerance].
  ///
  /// The [area] of the [svg] fitted within the [size] is its bounds by
  /// default, see [SvgPaths.render].
  static SvgPathsHitbox createSvgPathsHitbox(
    SvgPaths svg,
    Vector2? size, {
    bool? renderHitboxes,
    bool? filter,
    double sampling = 1.0,
    double? tolerance,
    Rect? area,
  }) {
    final (:full, :fit, :offset) = _layout(svg, size, area);
    final (:pathSampling, :pathTolerance) = _toPathUnits(
      sampling,
      tolerance,
      fit,
    );
    final combined = Path();
    for (var svgIndex = 0; svgIndex < svg.length; ++svgIndex) {
      combined.addPath(
        _hitboxPath(svg.pathAt(svgIndex)),
        Offset.zero,
      );
    }
    final hitbox = SvgPathsHitbox(
      path: combined,
      sampling: pathSampling,
      tolerance: pathTolerance,
      filter: filter ?? true,
      position:
          (combined.getBounds().topLeft - full.topLeft).toVector2() * fit +
          offset,
    )..scale.setValues(fit, fit);
    if (renderHitboxes ?? false) {
      hitbox
        ..renderShape = true
        ..paint = _whiteStroke();
    }
    return hitbox;
  }

  /// The [sampling] and [tolerance] in the units of the SVG paths, given the
  /// ones in the units of the component, which are [fit] times larger.
  static ({double pathSampling, double? pathTolerance}) _toPathUnits(
    double sampling,
    double? tolerance,
    double fit,
  ) {
    // A component without an area shrinks the paths to nothing, so their
    // polygons are only sampled in the units of the SVG file.
    final scale = fit > 0 ? fit : 1;
    return (
      pathSampling: sampling / scale,
      pathTolerance: tolerance == null ? null : tolerance / scale,
    );
  }

  /// The path to make hitboxes from, which has its open contours closed if
  /// it is filled, like filling does implicitly.
  static Path _hitboxPath(VectorPath path) {
    return path.paint.isFilled ? _closeContours(path.path) : path.path;
  }

  /// Returns the [path] with all of its contours closed, or the [path] itself
  /// if they already are.
  static Path _closeContours(Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.every((metric) => metric.isClosed)) {
      return path;
    }
    final closed = Path()..fillType = path.fillType;
    for (final metric in metrics) {
      closed.addPath(
        metric.extractPath(0, metric.length)..close(),
        Offset.zero,
      );
    }
    return closed;
  }
}
