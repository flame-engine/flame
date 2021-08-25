import 'dart:typed_data';
import 'dart:ui';
import 'package:test/fake.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_test/flutter_test.dart';

/// [MockCanvas] is a utility class for writing tests. It supports the same API
/// as the regular [Canvas] class from dart:ui (in theory; any missing commands
/// can be added as the need arises). In addition, this class is also a
/// [Matcher], allowing it to be used in `expect()` calls:
/// ```dart
/// final canvas = MockCanvas();
/// // ... draw something on the canvas
/// // then check that the commands issued were the ones that you'd expect:
/// expect(
///   canvas,
///   MockCanvas()
///     ..translate(10, 10)
///     ..drawRect(const Rect.fromLTWH(0, 0, 100, 100)),
/// );
/// ```
///
/// Two mock canvases will match only if they have the same number of commands,
/// and if each pair of corresponding commands matches.
///
/// Multiple transform commands (`translate()`, `scale()`, `rotate()` and
/// `transform()`) that are issued in a row are always joined into a single
/// combined transform. Thus, for example, calling `translate(10, 10)` and
/// then `translate(30, -10)` will match a single call `translate(40, 0)`.
///
/// Some commands can be partially specified. For example, in `drawLine()` and
/// `drawRect()` the `paint` argument is optional. If provided, it will be
/// checked against the actual Paint used, but if omitted, the match will still
/// succeed.
///
/// Commands that involve numeric components (i.e. coordinates, dimensions,
/// etc) will be matched approximately, with the default absolute tolerance of
/// 1e-10.
class MockCanvas extends Fake implements Canvas, Matcher {
  MockCanvas()
      : _commands = [],
        _saveCount = 0;

  final List<_CanvasCommand> _commands;
  int _saveCount;

  //#region Matcher API

  @override
  bool matches(covariant MockCanvas other, Map matchState) {
    if (_saveCount != 0) {
      return _fail('Canvas finished with saveCount=$_saveCount', matchState);
    }
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
    description.add('Canvas$_commands');
    return description;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(matchState['description'] as String);
  }

  //#endregion

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
  void clipRect(Rect rect,
      {ClipOp clipOp = ClipOp.intersect, bool doAntiAlias = true}) {
    _commands.add(_ClipRectCommand(rect, clipOp, doAntiAlias));
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
  void drawParagraph(Paragraph? paragraph, Offset offset) {
    _commands.add(_ParagraphCommand(offset));
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

/// This class encapsulates a single command that was issued to a [MockCanvas].
/// Most methods of [MockCanvas] will use a dedicated class derived from
/// [_CanvasCommand] to store all the arguments and then match them against
/// the expected values.
///
/// Each subclass is expected to implement two methods:
///   - `equals()`, which compares the current object against another instance
///     of the same class; and
///   - `toString()`, which is used when printing error messages in case of a
///     mismatch.
///
/// Use helper function `eq()` to implement the first method, and `repr()` to
/// implement the second.
abstract class _CanvasCommand {
  double tolerance = 1e-10;

  /// Return true if this command is equal to [other], up to the
  /// given absolute [tolerance]. The argument [other] is guaranteed
  /// to have the same type as the current command.
  bool equals(covariant _CanvasCommand other);

  /// Helper function to check the equality of any two objects.
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

  /// Helper function to generate string representations of various
  /// components of a command.
  String repr(dynamic a) {
    if (a is Offset) {
      return 'Offset(${a.dx}, ${a.dy})';
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

  List<double> _rectAsList(Rect rect) =>
      [rect.left, rect.top, rect.right, rect.bottom];

  List<double> _rrectAsList(RRect rect) => [
        rect.left,
        rect.top,
        rect.right,
        rect.bottom,
        rect.tlRadiusX,
        rect.tlRadiusY,
        rect.trRadiusX,
        rect.trRadiusY,
        rect.blRadiusX,
        rect.blRadiusY,
        rect.brRadiusX,
        rect.brRadiusY,
      ];

  List _paintAsList(Paint paint) =>
      <dynamic>[paint.color, paint.blendMode, paint.style, paint.strokeWidth];
}

class _TransformCanvasCommand extends _CanvasCommand {
  _TransformCanvasCommand() : _transform = Matrix4.identity();

  final Matrix4 _transform;

  void transform(Float64List matrix) =>
      _transform.multiply(Matrix4.fromFloat64List(matrix));
  void translate(double dx, double dy) => _transform.translate(dx, dy);
  void rotate(double angle) => _transform.rotateZ(angle);
  void scale(double sx, double sy) => _transform.scale(sx, sy, 1);

  @override
  bool equals(_TransformCanvasCommand other) =>
      eq(_transform.storage, other._transform.storage);

  @override
  String toString() {
    final content = _transform.storage.map((e) => e.toString()).join(', ');
    return 'transform($content)';
  }
}

/// canvas.clipRect()
class _ClipRectCommand extends _CanvasCommand {
  _ClipRectCommand(this.clipRect, this.clipOp, this.doAntiAlias);

  final Rect clipRect;
  final ClipOp clipOp;
  final bool doAntiAlias;

  @override
  bool equals(_ClipRectCommand other) =>
      eq(clipRect, other.clipRect) &&
      clipOp == other.clipOp &&
      doAntiAlias == other.doAntiAlias;

  @override
  String toString() {
    return 'clipRect(${repr(clipRect)}, clipOp=$clipOp, doAntiAlias=$doAntiAlias)';
  }
}

/// canvas.drawLine()
class _LineCommand extends _CanvasCommand {
  _LineCommand(this.p1, this.p2, this.paint);
  final Offset p1;
  final Offset p2;
  final Paint? paint;

  @override
  bool equals(_LineCommand other) =>
      eq(p1, other.p1) && eq(p2, other.p2) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawLine(${repr(p1)}, ${repr(p2)}, ${repr(paint)})';
  }
}

/// canvas.drawRect()
class _RectCommand extends _CanvasCommand {
  _RectCommand(this.rect, this.paint);
  final Rect rect;
  final Paint? paint;

  @override
  bool equals(_RectCommand other) =>
      eq(rect, other.rect) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawRect(${repr(rect)}, ${repr(paint)})';
  }
}

/// canvas.drawRRect()
class _RRectCommand extends _CanvasCommand {
  _RRectCommand(this.rrect, this.paint);
  final RRect rrect;
  final Paint? paint;

  @override
  bool equals(_RRectCommand other) =>
      eq(rrect, other.rrect) && eq(paint, other.paint);

  @override
  String toString() {
    return 'drawRRect(${repr(rrect)}, ${repr(paint)})';
  }
}

/// canvas.drawParagraph()
class _ParagraphCommand extends _CanvasCommand {
  _ParagraphCommand(this.offset);
  final Offset offset;

  @override
  bool equals(_ParagraphCommand other) => eq(offset, other.offset);

  @override
  String toString() {
    return 'drawParagraph(${repr(offset)})';
  }
}
