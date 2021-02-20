import 'dart:ui';

import 'package:test/fake.dart';

class MockCanvas extends Fake implements Canvas {
  int saveCount = 1;
  List<String> methodCalls = [];

  @override
  void translate(double dx, double dy) {
    methodCalls.add('translate($dx, $dy)');
  }

  @override
  void scale(double sx, [double sy]) {
    methodCalls.add('scale($sx, $sy)');
  }

  @override
  void rotate(double radians) {
    methodCalls.add('rotate($radians)');
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    methodCalls.add('drawRect(${rect.topLeft}, ${rect.width}, ${rect.height})');
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
