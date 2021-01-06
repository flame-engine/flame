import 'dart:ui';

import 'package:test/fake.dart';

class MockCanvas extends Fake implements Canvas {
  int saveCount = 0;
  int saveCountDelta = 1;

  @override
  void translate(double dx, double dy) {}

  @override
  void scale(double sx, [double? sy]) {}

  @override
  void rotate(double radians) {}

  @override
  int getSaveCount() {
    return saveCount += saveCountDelta;
  }

  @override
  void restore() {}

  @override
  void save() {}
}
