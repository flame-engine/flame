import 'dart:ui' as ui;

import 'package:flame_svg/vector_graphics_compiler_extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vgc;

void main() {
  group('BlendModeConverter', () {
    test('converts every blend mode to the one with the same name', () {
      for (final mode in vgc.BlendMode.values) {
        expect(
          mode.toUiBlendMode(),
          ui.BlendMode.values.byName(mode.name),
          reason: mode.name,
        );
      }
    });
  });

  group('StrokeCapConverter', () {
    test('converts every stroke cap to the one with the same name', () {
      for (final cap in vgc.StrokeCap.values) {
        expect(
          cap.toUiStrokeCap(),
          ui.StrokeCap.values.byName(cap.name),
          reason: cap.name,
        );
      }
    });
  });

  group('StrokeJoinConverter', () {
    test('converts every stroke join to the one with the same name', () {
      for (final join in vgc.StrokeJoin.values) {
        expect(
          join.toUiStrokeJoin(),
          ui.StrokeJoin.values.byName(join.name),
          reason: join.name,
        );
      }
    });
  });

  group('TileModeConverter', () {
    test('converts every tile mode to the one with the same name', () {
      for (final mode in vgc.TileMode.values) {
        expect(
          mode.toUiTileMode(),
          ui.TileMode.values.byName(mode.name),
          reason: mode.name,
        );
      }
    });
  });

  group('GradientConverter', () {
    const colors = [
      vgc.Color.fromARGB(255, 255, 0, 0),
      vgc.Color.fromARGB(255, 0, 0, 255),
    ];
    const offsets = [0.0, 1.0];

    test('converts a linear gradient', () {
      for (final tileMode in [null, ...vgc.TileMode.values]) {
        for (final transform in [null, vgc.AffineMatrix.identity]) {
          expect(
            vgc.LinearGradient(
              id: 'linear',
              from: vgc.Point.zero,
              to: const vgc.Point(10, 10),
              colors: colors,
              offsets: offsets,
              tileMode: tileMode,
              unitMode: vgc.GradientUnitMode.transformed,
              transform: transform,
            ).toUiGradient(),
            isA<ui.Gradient>(),
            reason: '$tileMode, $transform',
          );
        }
      }
    });

    test('converts a radial gradient', () {
      for (final focalPoint in [null, const vgc.Point(2, 3)]) {
        for (final transform in [null, vgc.AffineMatrix.identity]) {
          expect(
            vgc.RadialGradient(
              id: 'radial',
              center: const vgc.Point(5, 5),
              radius: 5,
              colors: colors,
              offsets: offsets,
              tileMode: vgc.TileMode.mirror,
              transform: transform,
              focalPoint: focalPoint,
              unitMode: vgc.GradientUnitMode.transformed,
            ).toUiGradient(),
            isA<ui.Gradient>(),
            reason: '$focalPoint, $transform',
          );
        }
      }
    });

    test('has no gradient without colors', () {
      expect(
        const vgc.LinearGradient(
          id: 'linear',
          from: vgc.Point.zero,
          to: vgc.Point(10, 10),
        ).toUiGradient(),
        isNull,
      );
      expect(
        const vgc.RadialGradient(
          id: 'radial',
          center: vgc.Point(5, 5),
          radius: 5,
        ).toUiGradient(),
        isNull,
      );
      expect(
        const vgc.LinearGradient(
          id: 'linear',
          from: vgc.Point.zero,
          to: vgc.Point(10, 10),
          colors: [],
          offsets: [],
        ).toUiGradient(),
        isNull,
      );
    });

    test('asserts that the bounds have been applied', () {
      for (final unitMode in [
        vgc.GradientUnitMode.objectBoundingBox,
        vgc.GradientUnitMode.userSpaceOnUse,
      ]) {
        expect(
          () => vgc.LinearGradient(
            id: 'linear',
            from: vgc.Point.zero,
            to: const vgc.Point(10, 10),
            colors: colors,
            offsets: offsets,
            unitMode: unitMode,
          ).toUiGradient(),
          throwsAssertionError,
          reason: unitMode.name,
        );
      }
    });
  });

  group('PaintConverter', () {
    const color = vgc.Color.fromARGB(255, 10, 20, 30);
    const gradient = vgc.LinearGradient(
      id: 'linear',
      from: vgc.Point.zero,
      to: vgc.Point(10, 10),
      colors: [color, color],
      offsets: [0, 1],
      unitMode: vgc.GradientUnitMode.transformed,
    );

    test('converts the shader of a fill', () {
      expect(
        const vgc.Paint(
          fill: vgc.Fill(color: color, shader: gradient),
        ).toFilledUiPaint()!.shader,
        isA<ui.Gradient>(),
      );
      expect(
        const vgc.Paint(fill: vgc.Fill(color: color)).toFilledUiPaint()!.shader,
        isNull,
      );
    });

    test('converts the shader of a stroke', () {
      expect(
        const vgc.Paint(
          stroke: vgc.Stroke(color: color, width: 1, shader: gradient),
        ).toStrokedUiPaint()!.shader,
        isA<ui.Gradient>(),
      );
      expect(
        const vgc.Paint(
          stroke: vgc.Stroke(color: color, width: 1),
        ).toStrokedUiPaint()!.shader,
        isNull,
      );
    });

    test('paints nothing with a gradient without colors', () {
      const empty = vgc.LinearGradient(
        id: 'empty',
        from: vgc.Point.zero,
        to: vgc.Point(10, 10),
        unitMode: vgc.GradientUnitMode.transformed,
      );
      expect(
        const vgc.Paint(
          fill: vgc.Fill(color: color, shader: empty),
        ).toFilledUiPaint(),
        isNull,
      );
      expect(
        const vgc.Paint(
          stroke: vgc.Stroke(color: color, width: 1, shader: empty),
        ).toStrokedUiPaint(),
        isNull,
      );
    });

    test('converts a fill', () {
      final paint = const vgc.Paint(
        fill: vgc.Fill(color: color),
        blendMode: vgc.BlendMode.multiply,
      ).toFilledUiPaint()!;
      expect(paint.style, ui.PaintingStyle.fill);
      expect(paint.color.toARGB32(), 0xff0a141e);
      expect(paint.blendMode, ui.BlendMode.multiply);
    });

    test('has no filled paint without a fill', () {
      expect(const vgc.Paint().toFilledUiPaint(), isNull);
    });

    test('converts a stroke', () {
      final paint = const vgc.Paint(
        stroke: vgc.Stroke(
          color: color,
          width: 3,
          miterLimit: 7,
          cap: vgc.StrokeCap.round,
          join: vgc.StrokeJoin.bevel,
        ),
      ).toStrokedUiPaint()!;
      expect(paint.style, ui.PaintingStyle.stroke);
      expect(paint.color.toARGB32(), 0xff0a141e);
      expect(paint.strokeWidth, 3);
      expect(paint.strokeCap, ui.StrokeCap.round);
      expect(paint.strokeJoin, ui.StrokeJoin.bevel);
    });

    test('keeps the defaults of the cap and the join if there are none', () {
      final paint = const vgc.Paint(
        stroke: vgc.Stroke(color: color, width: 3),
      ).toStrokedUiPaint()!;
      final defaults = ui.Paint();
      expect(paint.strokeCap, defaults.strokeCap);
      expect(paint.strokeJoin, defaults.strokeJoin);
    });

    testWidgets(
      'keeps the default miter limit if there is none',
      (tester) async {
        // A right angle with a miter join: the miter point of the corner only
        // appears with the default limit of 4, and not with a limit of 0.
        Future<int> alphaAtMiterTip(ui.Paint paint) async {
          paint.strokeWidth = 10;
          paint.strokeJoin = ui.StrokeJoin.miter;
          return (await tester.runAsync(() async {
            final recorder = ui.PictureRecorder();
            final path = ui.Path()
              ..moveTo(10, 10)
              ..lineTo(60, 10)
              ..lineTo(60, 60);
            ui.Canvas(recorder).drawPath(path, paint);
            final image = await recorder.endRecording().toImage(100, 100);
            final data = (await image.toByteData())!;
            // Near the outer corner, at (65, 5).
            return data.getUint8((6 * 100 + 64) * 4 + 3);
          }))!;
        }

        final converted = const vgc.Paint(
          stroke: vgc.Stroke(color: color, width: 10),
        ).toStrokedUiPaint()!;
        final expected = await alphaAtMiterTip(ui.Paint()..style = .stroke);
        expect(await alphaAtMiterTip(converted), expected);
      },
    );

    test('has the SVG default width for a stroke without a width', () {
      final paint = const vgc.Paint(
        stroke: vgc.Stroke(color: color),
      ).toStrokedUiPaint();
      expect(paint, isNotNull);
      expect(paint!.strokeWidth, 1);
    });

    test('has the SVG default width for a stroke with a negative width', () {
      final paint = const vgc.Paint(
        stroke: vgc.Stroke(color: color, width: -1),
      ).toStrokedUiPaint();
      expect(paint, isNotNull);
      expect(paint!.strokeWidth, 1);
    });

    test('has no stroked paint without a stroke or with a zero width', () {
      expect(const vgc.Paint().toStrokedUiPaint(), isNull);
      expect(
        const vgc.Paint(
          stroke: vgc.Stroke(color: color, width: 0),
        ).toStrokedUiPaint(),
        isNull,
      );
    });

    test('converts to a VectorPaint with both a fill and a stroke', () {
      final paint = const vgc.Paint(
        fill: vgc.Fill(color: color),
        stroke: vgc.Stroke(color: color, width: 2),
      ).toVectorPaint();
      expect(paint.isFilled, isTrue);
      expect(paint.isStroked, isTrue);
    });
  });

  group('PathConverter', () {
    vgc.Path vgcPath([
      vgc.PathFillType fillType = vgc.PathFillType.nonZero,
    ]) {
      return (vgc.PathBuilder(fillType)
            ..moveTo(0, 0)
            ..lineTo(10, 0)
            ..cubicTo(10, 5, 5, 10, 0, 10)
            ..close())
          .toPath();
    }

    test('converts the commands', () {
      final path = vgcPath().toUiPath();
      expect(path.getBounds().left, 0);
      expect(path.getBounds().right, 10);
      final metrics = path.computeMetrics().toList();
      expect(metrics.length, 1);
      expect(metrics.single.isClosed, isTrue);
    });

    test('converts the fill type', () {
      expect(vgcPath().toUiPath().fillType, ui.PathFillType.nonZero);
      expect(
        vgcPath(vgc.PathFillType.evenOdd).toUiPath().fillType,
        ui.PathFillType.evenOdd,
      );
    });

    test('converts to a VectorPath', () {
      final paint = const vgc.Paint(
        fill: vgc.Fill(color: vgc.Color.fromARGB(255, 1, 2, 3)),
      ).toVectorPaint();
      final vectorPath = vgcPath().toVectorPath(paint);
      expect(vectorPath.paint, paint);
      expect(vectorPath.path.getBounds(), const ui.Rect.fromLTRB(0, 0, 10, 10));
    });
  });
}
