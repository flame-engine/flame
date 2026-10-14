import 'dart:ui' as ui;

import 'package:flame_svg/vector_paint.dart';
import 'package:flame_svg/vector_path.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// [BlendMode] mapping from the vector graphics compiler.
extension BlendModeConverter on BlendMode {
  /// Converts a [BlendMode] to a [ui.BlendMode].
  ui.BlendMode toUiBlendMode() => switch (this) {
    .clear => .clear,
    .color => .color,
    .colorBurn => .colorBurn,
    .colorDodge => .colorDodge,
    .darken => .darken,
    .difference => .difference,
    .dst => .dst,
    .dstATop => .dstATop,
    .dstIn => .dstIn,
    .dstOut => .dstOut,
    .dstOver => .dstOver,
    .exclusion => .exclusion,
    .hardLight => .hardLight,
    .hue => .hue,
    .lighten => .lighten,
    .luminosity => .luminosity,
    .modulate => .modulate,
    .multiply => .multiply,
    .overlay => .overlay,
    .plus => .plus,
    .saturation => .saturation,
    .screen => .screen,
    .softLight => .softLight,
    .src => .src,
    .srcATop => .srcATop,
    .srcIn => .srcIn,
    .srcOut => .srcOut,
    .srcOver => .srcOver,
    .xor => .xor,
  };
}

/// [StrokeCap] mapping from the vector graphics compiler.
extension StrokeCapConverter on StrokeCap {
  /// Converts a [StrokeCap] to a [ui.StrokeCap].
  ui.StrokeCap toUiStrokeCap() => switch (this) {
    .butt => .butt,
    .round => .round,
    .square => .square,
  };
}

/// [StrokeJoin] mapping from the vector graphics compiler.
extension StrokeJoinConverter on StrokeJoin {
  /// Converts a [StrokeJoin] to a [ui.StrokeJoin].
  ui.StrokeJoin toUiStrokeJoin() => switch (this) {
    .miter => .miter,
    .round => .round,
    .bevel => .bevel,
  };
}

/// [TileMode] mapping from the vector graphics compiler.
extension TileModeConverter on TileMode {
  /// Converts a [TileMode] to a [ui.TileMode].
  ui.TileMode toUiTileMode() => switch (this) {
    .clamp => .clamp,
    .repeated => .repeated,
    .mirror => .mirror,
    .decal => .decal,
  };
}

/// [Gradient] conversion from the vector graphics compiler.
extension GradientConverter on Gradient {
  /// Possibly converts a [Gradient] to a [ui.Gradient].
  ///
  /// The gradient must already have its bounds applied (see
  /// [Gradient.applyBounds]), so that its [Gradient.unitMode] is
  /// [GradientUnitMode.transformed]: this is always the case for gradients
  /// coming from parsed [VectorInstructions].
  ///
  /// Returns `null` if the gradient has no [Gradient.colors], in which case
  /// SVG paints nothing with it.
  ui.Gradient? toUiGradient() {
    assert(
      unitMode == null || unitMode == GradientUnitMode.transformed,
      'Gradient bounds must be applied before conversion',
    );
    final c = colors;
    if (c == null || c.isEmpty) {
      return null;
    }
    final uiColors = [for (final color in c) ui.Color(color.value)];
    final uiTileMode = tileMode?.toUiTileMode() ?? ui.TileMode.clamp;
    final matrix4 = transform?.toMatrix4();
    final g = this;
    if (g is LinearGradient) {
      return ui.Gradient.linear(
        ui.Offset(g.from.x, g.from.y),
        ui.Offset(g.to.x, g.to.y),
        uiColors,
        offsets,
        uiTileMode,
        matrix4,
      );
    } else if (g is RadialGradient) {
      final f = g.focalPoint;
      // The vector graphics compiler has no focal radius, so we keep the
      // default of zero.
      return ui.Gradient.radial(
        ui.Offset(g.center.x, g.center.y),
        g.radius,
        uiColors,
        offsets,
        uiTileMode,
        matrix4,
        f == null ? null : ui.Offset(f.x, f.y),
      );
    }
    return null;
  }
}

/// Paint conversion from the vector graphics compiler.
extension PaintConverter on Paint {
  /// Converts a [Paint] to a [VectorPaint].
  VectorPaint toVectorPaint() {
    return VectorPaint(stroke: toStrokedUiPaint(), fill: toFilledUiPaint());
  }

  /// Possibly converts a stroked [Paint] to a [ui.Paint].
  ///
  /// A stroke without a width, or with an invalid negative one, has the SVG
  /// default width of 1, and a stroke with a width of zero, or with a gradient
  /// that can not be converted (see [GradientConverter.toUiGradient]), is not
  /// painted.
  ui.Paint? toStrokedUiPaint() {
    final s = stroke;
    final w = s?.width;
    final width = w == null || w < 0 ? 1.0 : w;
    if (s == null || width == 0) {
      return null;
    }
    final shader = s.shader?.toUiGradient();
    if (s.shader != null && shader == null) {
      return null;
    }
    final p = ui.Paint();
    p.style = .stroke;
    p.blendMode = blendMode.toUiBlendMode();
    p.strokeWidth = width;
    p.color = ui.Color(s.color.value);
    p.shader = shader;
    // Without a miter limit we keep the default of the engine: reading it
    // back from the paint and assigning it gives a different value.
    final m = s.miterLimit;
    if (m != null) {
      p.strokeMiterLimit = m;
    }
    final c = s.cap;
    if (c != null) {
      p.strokeCap = c.toUiStrokeCap();
    }
    final j = s.join;
    if (j != null) {
      p.strokeJoin = j.toUiStrokeJoin();
    }
    return p;
  }

  /// Possibly converts a filled [Paint] to a [ui.Paint].
  ///
  /// A fill with a gradient that can not be converted (see
  /// [GradientConverter.toUiGradient]) is not painted.
  ui.Paint? toFilledUiPaint() {
    final f = fill;
    if (f == null) {
      return null;
    }
    final shader = f.shader?.toUiGradient();
    if (f.shader != null && shader == null) {
      return null;
    }
    final p = ui.Paint();
    p.style = .fill;
    p.blendMode = blendMode.toUiBlendMode();
    p.color = ui.Color(f.color.value);
    p.shader = shader;
    return p;
  }
}

/// Path conversion from the vector graphics compiler.
extension PathConverter on Path {
  /// Converts a [Path] to a [VectorPath], using the provided [paint].
  VectorPath toVectorPath(VectorPaint paint) => VectorPath(toUiPath(), paint);

  /// Converts a [Path] to a [ui.Path].
  ui.Path toUiPath() {
    final p = ui.Path()
      ..fillType = switch (fillType) {
        .nonZero => .nonZero,
        .evenOdd => .evenOdd,
      };
    for (final c in commands) {
      if (c is MoveToCommand) {
        p.moveTo(c.x, c.y);
      } else if (c is LineToCommand) {
        p.lineTo(c.x, c.y);
      } else if (c is CubicToCommand) {
        p.cubicTo(c.x1, c.y1, c.x2, c.y2, c.x3, c.y3);
      } else if (c is CloseCommand) {
        p.close();
      }
    }
    return p;
  }
}
