import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/game/transform2d.dart';
import 'package:test/fake.dart';
import 'package:vector_math/vector_math_64.dart';

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


class MokkCanvas extends Fake implements Canvas {
  MokkCanvas()
    : _commands = [];

  final List<_CanvasCommand> _commands;

  @override
  void translate(double dx, double dy) {
    _currentTransform.translate(dx, dy);
  }

  _Transform2DCanvasCommand get _currentTransform {
    if (_commands.isNotEmpty && _commands.last is _Transform2DCanvasCommand) {
      return _commands.last as _Transform2DCanvasCommand;
    }
    final transform2d = _Transform2DCanvasCommand();
    _commands.add(transform2d);
    return transform2d;
  }
}

abstract class _CanvasCommand {

}

class _Transform2DCanvasCommand extends _CanvasCommand {
  _Transform2DCanvasCommand()
    : _transform = Transform2D();

  final Transform2D _transform;

  void translate(double dx, double dy) => _transform.position += Vector2(dx, dy);
  void rotate(double angle) => _transform.angle += angle;
}
