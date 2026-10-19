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

  /// A [PathHitbox] for each path, which are all children of the
  /// [SvgPathsComponent]. The paths of the same file do not collide with each
  /// other.
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
  ///
  /// The hitboxes follow the [size] of the component when it changes, but
  /// their polygons keep the [sampling] and [tolerance] of the initial size.
  this : super(size: size ?? svg.bounds.size.toVector2()) {
    addAll(_pathHitboxes);
    final hitbox = _hitbox;
    if (hitbox != null) {
      add(hitbox);
    }
    this.size.addListener(_placeHitboxes);
  }

  /// The children with [SvgHitboxes.perPath].
  final List<PathHitbox> _pathHitboxes = hitboxes == SvgHitboxes.perPath
      ? createPathHitboxes(
          svg,
          size,
          renderHitboxes: renderHitboxes,
          filter: filter,
          sampling: sampling,
          tolerance: tolerance,
        )
      : const [];

  /// The child with [SvgHitboxes.single], unless the [svg] is empty.
  final SvgPathsHitbox? _hitbox =
      hitboxes == SvgHitboxes.single && svg.length > 0
      ? SvgPathsHitbox.fromSvg(
          svg,
          size,
          renderHitboxes: renderHitboxes,
          filter: filter,
          sampling: sampling,
          tolerance: tolerance,
        )
      : null;

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

  @override
  void render(Canvas canvas) {
    svg.render(canvas, size, area: svg.bounds);
  }

  void _placeHitboxes() {
    if (_pathHitboxes.isNotEmpty) {
      placePathHitboxes(_pathHitboxes, svg, size);
    }
    _hitbox?.place(size);
  }

  // Each hitbox gets its own paint, so that changing the paint of one does not
  // change the others.
  static Paint _whiteStroke() => Paint()
    ..color = const Color(0xffffffff)
    ..style = PaintingStyle.stroke;

  /// How the bounds of the [svg] fit within the [size], by default the size
  /// of those bounds, see [SvgPaths.fit].
  static ({Rect area, double scale, Vector2 offset}) _fit(
    SvgPaths svg,
    Vector2? size,
  ) {
    return svg.fit(size ?? svg.bounds.size.toVector2(), area: svg.bounds);
  }

  /// Creates a [PathHitbox] for each path in the [svg], as with
  /// [SvgHitboxes.perPath].
  ///
  /// The paths are scaled to fit within the [size] of the component while
  /// keeping the aspect ratio, and are centered within it. This way the
  /// center of the component is the center of the SVG contents, which is what
  /// the component rotates and scales around.
  ///
  /// The [sampling] and [tolerance] of the polygons, see [PathComponent.new],
  /// are in the units of the [size], and not in those of the SVG file.
  static List<PathHitbox> createPathHitboxes(
    SvgPaths svg,
    Vector2? size, {
    bool? renderHitboxes,
    bool? filter,
    double sampling = 1.0,
    double? tolerance,
  }) {
    // A component without an area shrinks the paths to nothing, so their
    // polygons are only sampled in the units of the SVG file.
    final fit = _fit(svg, size).scale;
    final units = fit > 0 ? fit : 1;
    final pathSampling = sampling / units;
    final pathTolerance = tolerance == null ? null : tolerance / units;
    final hitboxes = <PathHitbox>[];
    for (var svgIndex = 0; svgIndex < svg.length; ++svgIndex) {
      // Filling a path closes its open contours implicitly, but the polygons
      // of a PathHitbox only come from closed contours: without closing them,
      // the filled areas of open contours would be missing from the hitbox.
      final hitbox = PathHitbox(
        path: svg.pathAt(svgIndex).hitboxPath,
        sampling: pathSampling,
        tolerance: pathTolerance,
        filter: filter ?? true,
      );
      if (renderHitboxes ?? false) {
        hitbox
          ..renderShape = true
          ..paint = _whiteStroke();
      }
      hitboxes.add(hitbox);
    }
    placePathHitboxes(hitboxes, svg, size);
    return hitboxes;
  }

  /// Places the [hitboxes] made by [createPathHitboxes] for the [svg] within
  /// the given [size], like after their parent is resized.
  ///
  /// Their polygons are not made again, so they keep the sampling and the
  /// tolerance of the size that they were made for.
  static void placePathHitboxes(
    List<PathHitbox> hitboxes,
    SvgPaths svg,
    Vector2? size,
  ) {
    assert(
      hitboxes.length == svg.length,
      'There must be a hitbox for each path',
    );
    final (:area, scale: fit, :offset) = _fit(svg, size);
    for (var svgIndex = 0; svgIndex < svg.length; ++svgIndex) {
      // A PathHitbox moves its path to the origin, so we restore its position
      // within the SVG.
      final topLeft = svg.pathAt(svgIndex).hitboxPath.getBounds().topLeft;
      hitboxes[svgIndex]
        ..position = (topLeft - area.topLeft).toVector2() * fit + offset
        ..scale.setValues(fit, fit);
    }
  }
}
