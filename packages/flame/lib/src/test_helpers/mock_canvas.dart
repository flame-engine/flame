import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:test/fake.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCanvas extends Fake implements Canvas {
  int saveCount = 1;
  List<String> methodCalls = [];

  @override
  void translate(double dx, double dy) {
    final ddx = _normalize(dx);
    final ddy = _normalize(dy);
    methodCalls.add('translate($ddx, $ddy)');
  }

  @override
  void scale(double sx, [double? sy]) {
    final ssx = _normalize(sx);
    if (sy == null) {
      methodCalls.add('scale($ssx)');
    } else {
      final ssy = _normalize(sy);
      methodCalls.add('scale($ssx, $ssy)');
    }
  }

  double _normalize(double d) {
    // this prevents it from printing -0 which would be harder to assert in tests
    return _isNegativeZero(d) ? 0.0 : d;
  }

  bool _isNegativeZero(double d) {
    return d.abs() == 0.0 && d.isNegative;
  }

  @override
  void rotate(double radians) {
    methodCalls.add('rotate($radians)');
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    methodCalls.add(
      'drawRect(${rect.left}, ${rect.top}, ${rect.width}, ${rect.height})',
    );
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    methodCalls.add(
      'drawLine(${p1.dx}, ${p1.dy}, ${p2.dx}, ${p2.dy})',
    );
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    // There appears to be no way of extracting text content from the
    // [paragraph].
    methodCalls.add(
      'drawParagraph(?, ${offset.dx}, ${offset.dy})',
    );
  }

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    methodCalls.add(
      'clipRect(${rect.left}, ${rect.top}, ${rect.width}, ${rect.height})',
    );
  }

  @override
  void transform(Float64List matrix4) {
    final asString = matrix4.map<String>((e) => e.toString()).join(', ');
    methodCalls.add('transform($asString)');
  }

  @override
  int getSaveCount() {
    return saveCount;
  }

  @override
  void restore() {
    saveCount--;
  }

  @override
  void save() {
    saveCount++;
  }
}

//==================================================================================================

class MokkCanvas extends Fake implements Canvas, Matcher {
  MokkCanvas()
    : _commands = [],
      _saveCount = 1;

  final List<_CanvasCommand> _commands;
  int _saveCount;

  @override
  bool matches(covariant MokkCanvas other, Map matchState) {
    final n1 = _commands.length;
    final n2 = other._commands.length;
    if (n1 != n2) {
      return _fail(
        'Canvas contains $n1 commands, but $n2 expected',
        matchState,
      );
    }
    for (var i = 0; i < n1; i++) {
      final cmd1 = _commands[i];
      final cmd2 = other._commands[i];
      if (cmd1.runtimeType != cmd2.runtimeType) {
        return _fail(
          'Mismatched canvas commands at index $i: the actual '
          'command is ${cmd1.runtimeType}, while the expected '
          'was ${cmd2.runtimeType}',
          matchState,
        );
      }
      if (!cmd1.equals(cmd2)) {
        return _fail(
          'Mismatched canvas commands at index $i: the actual '
          'command is ${cmd1.toString()}, while the expected '
          'was ${cmd2.toString()}',
          matchState,
        );
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    description.add('Canvas[length=${_commands.length}]');
    return description;
  }

  @override
  Description describeMismatch(dynamic item, Description mismatchDescription,
      Map matchState, bool verbose)
    => mismatchDescription.add(matchState['description'] as String);

  //#region Canvas API

  @override
  void transform(Float64List matrix4) {
    _lastTransform.transform(matrix4);
  }

  @override
  void translate(double dx, double dy) {
    _lastTransform.translate(dx, dy);
  }

  @override
  void rotate(double angle) {
    _lastTransform.rotate(angle);
  }

  @override
  void scale(double sx, [double? sy]) {
    sy ??= sx;
    _lastTransform.scale(sx, sy);
  }

  @override
  void drawRect(Rect rect, [Paint? paint]) {
    _commands.add(_RectCommand(rect, paint));
  }

  @override
  void drawRRect(RRect rrect, [Paint? paint]) {
    _commands.add(_RRectCommand(rrect, paint));
  }

  @override
  void drawLine(Offset p1, Offset p2, [Paint? paint]) {
    _commands.add(_LineCommand(p1, p2, paint));
  }

  @override
  int getSaveCount() => _saveCount;

  @override
  void restore() => _saveCount--;

  @override
  void save() => _saveCount++;

  //#endregion

  //#region Private helpers

  _TransformCanvasCommand get _lastTransform {
    if (_commands.isNotEmpty && _commands.last is _TransformCanvasCommand) {
      return _commands.last as _TransformCanvasCommand;
    }
    final transform2d = _TransformCanvasCommand();
    _commands.add(transform2d);
    return transform2d;
  }

  bool _fail(String reason, Map state) {
    state['description'] = reason;
    return false;
  }

  //#endregion
}

abstract class _CanvasCommand {
  double tolerance = 1e-10;

  /// Return true if this command is equal to [other], up to the
  /// given absolute [tolerance]. The argument [other] is guaranteed
  /// to have the same type as the current command.
  bool equals(covariant _CanvasCommand other);

  bool eq(dynamic a, dynamic b) {
    if (a == null || b == null) {
      return true;
    }
    if (a is num && b is num) {
      return (a - b).abs() < tolerance;
    }
    if (a is Offset && b is Offset) {
      return eq(a.dx, b.dx) && eq(a.dy, b.dy);
    }
    if (a is List && b is List) {
      return a.length == b.length &&
        Iterable<int>.generate(a.length).every((i) => eq(a[i], b[i]));
    }
    if (a is Rect && b is Rect) {
      return eq(_rectAsList(a), _rectAsList(b));
    }
    if (a is RRect && b is RRect) {
      return eq(_rrectAsList(a), _rrectAsList(b));
    }
    if (a is Paint && b is Paint) {
      return eq(_paintAsList(a), _paintAsList(b));
    }
    return a == b;
  }

  String repr(dynamic a) {
    if (a is Offset) {
      return '[${a.dx}, ${a.dy}]';
    }
    if (a is List) {
      return a.map(repr).join(', ');
    }
    if (a is Rect) {
      return 'Rect(${repr(_rectAsList(a))})';
    }
    if (a is RRect) {
      return 'RRect(${repr(_rrectAsList(a))})';
    }
    if (a is Paint) {
      return 'Paint(${repr(_paintAsList(a))})';
    }
    return a.toString();
  }

  List<double> _rectAsList(Rect rect)
    => [rect.left, rect.top, rect.right, rect.bottom];

  List<double> _rrectAsList(RRect rect)
    => [rect.left, rect.top, rect.right, rect.bottom,
        rect.tlRadiusX, rect.tlRadiusY, rect.trRadiusX, rect.trRadiusY,
        rect.blRadiusX, rect.blRadiusY, rect.brRadiusX, rect.brRadiusY,];

  List _paintAsList(Paint paint)
    => <dynamic>[paint.color, paint.blendMode, paint.style, paint.strokeWidth];
}

class _TransformCanvasCommand extends _CanvasCommand {
  _TransformCanvasCommand()
    : _transform = Matrix4.identity();

  final Matrix4 _transform;

  void transform(Float64List matrix) => _transform.multiply(Matrix4.fromFloat64List(matrix));
  void translate(double dx, double dy) => _transform.translate(dx, dy);
  void rotate(double angle) => _transform.rotateZ(angle);
  void scale(double sx, double sy) => _transform.scale(sx, sy, 1);

  @override
  bool equals(_TransformCanvasCommand other)
    => eq(_transform.storage, other._transform.storage);

  @override
  String toString() {
    final content = _transform.storage.map((e) => e.toString()).join(', ');
    return 'transform($content)';
  }
}

class _LineCommand extends _CanvasCommand {
  _LineCommand(this.p1, this.p2, this.paint);
  final Offset p1;
  final Offset p2;
  final Paint? paint;

  @override
  bool equals(_LineCommand other)
    => eq(p1, other.p1) && eq(p2, other.p2) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawLine(${repr(p1)}, ${repr(p2)}, ${repr(paint)})';
  }
}

class _RectCommand extends _CanvasCommand {
  _RectCommand(this.rect, this.paint);
  final Rect rect;
  final Paint? paint;

  @override
  bool equals(_RectCommand other)
    => eq(rect, other.rect) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawRect(${repr(rect)}, ${repr(paint)})';
  }
}

class _RRectCommand extends _CanvasCommand {
  _RRectCommand(this.rrect, this.paint);
  final RRect rrect;
  final Paint? paint;

  @override
  bool equals(_RRectCommand other)
    => eq(rrect, other.rrect) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawRRect(${repr(rrect)}, ${repr(paint)})';
  }
}
