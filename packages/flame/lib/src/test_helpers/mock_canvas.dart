import 'dart:typed_data';
import 'dart:ui';

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


class MokkCanvas extends Fake implements Canvas, Matcher {
  MokkCanvas()
    : _commands = [];

  final List<_CanvasCommand> _commands;

  @override
  bool matches(covariant MokkCanvas item, Map matchState) {
    if (_commands.length != item._commands.length) {
      return _fail('Canvas contains ${_commands.length} commands, but '
                   '${item._commands.length} expected', matchState);
    }
    for (var i = 0; i < _commands.length; i++) {
      final cmd1 = _commands[i];
      final cmd2 = item._commands[i];
      if (cmd1.runtimeType != cmd2.runtimeType) {
        return _fail('Mismatched canvas commands at index $i: the actual '
                     'command is ${cmd1.runtimeType}, while the expected '
                     'was ${cmd2.runtimeType}', matchState);
      }
      if (!cmd1.matches(cmd2, matchState)) {
        return false;
      }
    }
    return true;
  }

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
  bool matches(covariant _CanvasCommand cmd, Map matchState);
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
  bool matches(_TransformCanvasCommand cmd, Map state) {
    final storage1 = _transform.storage;
    final storage2 = cmd._transform.storage;
    for (var i = 0; i < 16; i++) {

    }
    return true;
  }
}

class _LineCommand extends _CanvasCommand {
  _LineCommand(this.p1, this.p2, this.paint);
  final Offset p1;
  final Offset p2;
  final Paint? paint;
}

class _RectCommand extends _CanvasCommand {
  _RectCommand(this.rect, this.paint);
  final Rect rect;
  final Paint? paint;
}

class _RRectCommand extends _CanvasCommand {
  _RRectCommand(this.rrect, this.paint);
  final RRect rrect;
  final Paint? paint;
}
