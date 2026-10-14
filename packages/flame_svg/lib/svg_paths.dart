import 'dart:math' show max, min;
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_svg/vector_graphics_compiler_extensions.dart';
import 'package:flame_svg/vector_paint.dart';
import 'package:flame_svg/vector_path.dart';
import 'package:flutter/foundation.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// A container for SVG files, represented as a collection of [VectorPath]
/// and associated [VectorPaint] objects.
///
/// Only the paths of the SVG file are imported: clipping, masks, group
/// opacity, text, images and patterns are ignored, so an SVG file using them
/// may look different than in other renderers.
@immutable
class SvgPaths(String svg, {this.merge = true}) {
  /// Create from an [svg] string, and perform an optional [merge]
  /// of consecutive SVG paths sharing the same paint.
  ///
  /// Throws if the [svg] can not be parsed.
  this {
    _importSvg(svg);
  }

  /// Create an [SvgPaths] from a [fileName] in the `assets` folder,
  /// reachable via the [cache] (by default, [Flame.assets]), and
  /// optionally [merge] consecutive paths with identical paints.
  ///
  /// When a [package] is given, the [fileName] is resolved relative to the
  /// assets of that package.
  static Future<SvgPaths> fromFile(
    String fileName, {
    AssetsCache? cache,
    String? package,
    bool merge = true,
  }) async {
    final assets = cache ?? Flame.assets;
    final svg = await assets.readFile(fileName, package: package);
    return SvgPaths(svg, merge: merge);
  }

  /// Whether we merge consecutive paths with identical paints, which keeps
  /// the painting order of the SVG file. Paths with both a fill and a stroke,
  /// with a different fill type, or whose bounds, including their strokes,
  /// overlap those of the paths already merged, are not merged.
  final bool merge;

  /// The number of [VectorPath] objects in this container.
  int get length => _paths.length;

  /// The [VectorPath] at the given index, which must be less than [length].
  VectorPath pathAt(int index) => _paths[index];

  /// The [VectorPaint] of the [VectorPath] at the given index, see [pathAt].
  VectorPaint paintAt(int index) => _paths[index].paint;

  /// The original width reported by the [VectorInstructions].
  late final double width;

  /// The original height reported by the [VectorInstructions].
  late final double height;

  /// The original size reported by the [VectorInstructions].
  Size get size => Size(width, height);

  /// The bounds of the paths, without their strokes, or [ui.Rect.zero] if
  /// there are none.
  late final ui.Rect bounds = _computeBounds();

  /// Renders all paths on the [canvas], fitting the [area] of the SVG file
  /// into the dimensions in [size] while keeping the aspect ratio, and
  /// centering it. The [area] is the whole SVG file by default.
  ///
  /// An optional [overridePaint] is used instead of the [VectorPaint]s.
  void render(
    ui.Canvas canvas,
    Vector2 size, {
    ui.Paint? overridePaint,
    ui.Rect? area,
  }) {
    final source = area ?? ui.Rect.fromLTWH(0, 0, width, height);
    final scale = min(size.x / source.width, size.y / source.height);
    if (!scale.isFinite) {
      // There is nothing to fit, like in an empty SVG file.
      return;
    }
    canvas.save();
    canvas.translate(
      (size.x - source.width * scale) * 0.5 - source.left * scale,
      (size.y - source.height * scale) * 0.5 - source.top * scale,
    );
    canvas.scale(scale);

    final overrideVP = overridePaint != null
        ? VectorPaint.paint(overridePaint)
        : null;
    for (final path in _paths) {
      path.render(canvas, overrideVP);
    }

    canvas.restore();
  }

  /// Renders all paths on the [canvas] at the given [position] using the
  /// dimensions in [size], see [render].
  void renderPosition(
    ui.Canvas canvas,
    Vector2 position,
    Vector2 size, {
    ui.Paint? overridePaint,
    ui.Rect? area,
  }) {
    canvas.renderAt(
      position,
      (c) => render(c, size, overridePaint: overridePaint, area: area),
    );
  }

  // MARK: - Private methods

  void _importSvg(String svg) {
    // Only the size is kept from the instructions, which can be large.
    final instructions = parseWithoutOptimizers(svg);
    width = instructions.width;
    height = instructions.height;

    final paints = <int, VectorPaint>{};
    // The same path can be drawn with different paints, since the vector
    // graphics compiler shares the paths with the same data, so each
    // [VectorPath] is cached by both its path and its paint.
    final paths = <(int, int), VectorPath>{};

    // The run of consecutive paths that are going to be merged, which are
    // added to the result as soon as the run ends. Merging only consecutive
    // paths keeps the painting order of the SVG file, and merging only paths
    // whose painted bounds do not overlap keeps their appearance: overlapping
    // contours of a merged path could cancel each other out, depending on
    // their direction and on the fill type, and overlapping translucent paints
    // would not add up.
    final run = <VectorPath>[];
    final runBounds = <ui.Rect>[];
    int? runPaintId;

    void endRun() {
      if (run.isEmpty) {
        return;
      }
      if (run.length == 1) {
        _paths.add(run.first);
      } else {
        final merged = ui.Path()..fillType = run.first.path.fillType;
        for (final path in run) {
          merged.addPath(path.path, .zero);
        }
        // The paths of a run all share the same paint.
        _paths.add(VectorPath(merged, run.first.paint));
      }
      run.clear();
      runBounds.clear();
      runPaintId = null;
    }

    // Walk all vector instructions, considering only path commands.
    for (final c in instructions.commands) {
      if (c.type != .path) {
        // Other commands, like clipping, are not supported, but they still
        // separate the paths around them.
        endRun();
        continue;
      }

      final paintId = c.paintId;
      final pathId = c.objectId;
      assert(paintId != null && pathId != null, 'Invalid path or paint ID');
      if (paintId == null || pathId == null) {
        endRun();
        continue;
      }

      // Convert the paint and the path.
      final paint = paints[paintId] ??= instructions.paints[paintId]
          .toVectorPaint();
      if (!paint.isFilled && !paint.isStroked) {
        // Nothing is painted, like with a gradient without colors.
        continue;
      }
      final path = paths[(pathId, paintId)] ??= instructions.paths[pathId]
          .toVectorPath(paint);

      // Paths with both a fill and a stroke are never merged, since the fill
      // and stroke of a merged path are painted after all of its paths, which
      // would change the painting order. The same goes for paths with a
      // different fill type, which a merged path can only have one of.
      final canMerge = merge && !(paint.isFilled && paint.isStroked);
      final bounds = _paintedBounds(path);
      if (!canMerge ||
          paintId != runPaintId ||
          path.path.fillType != run.first.path.fillType ||
          runBounds.any(bounds.overlaps)) {
        endRun();
      }
      run.add(path);
      runBounds.add(bounds);
      runPaintId = paintId;
      if (!canMerge) {
        endRun();
      }
    }
    endRun();
  }

  /// The bounds of the [path], grown to include its stroke, if any. A miter
  /// join can reach up to the miter limit times half of the width of the
  /// stroke, and the other joins and caps less than twice that width.
  ui.Rect _paintedBounds(VectorPath path) {
    final bounds = path.path.getBounds();
    final stroke = path.paint.stroke;
    if (stroke == null) {
      return bounds;
    }
    final reach = stroke.strokeJoin == .miter
        ? max(2.0, stroke.strokeMiterLimit / 2)
        : 2.0;
    return bounds.inflate(stroke.strokeWidth * reach);
  }

  ui.Rect _computeBounds() {
    ui.Rect? bounds;
    for (final path in _paths) {
      final b = path.path.getBounds();
      bounds = bounds?.expandToInclude(b) ?? b;
    }
    return bounds ?? .zero;
  }

  final List<VectorPath> _paths = [];
}
