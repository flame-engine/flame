import 'dart:math';

import 'package:meta/meta.dart';

@internal
double collapseMargin(double margin1, double margin2) {
  if (margin1 >= 0) {
    return (margin2 < 0) ? margin1 + margin2 : max(margin1, margin2);
  } else {
    return (margin2 < 0) ? min(margin1, margin2) : margin1 + margin2;
  }
}
