import 'dart:typed_data';
import 'dart:ui';

import 'package:test/fake.dart';

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
