import 'package:flame/src/experimental/nullable_vector_2.dart';
import 'package:flutter/foundation.dart';

class NotifyingNullableVector2 extends NullableVector2 with ChangeNotifier {
  NotifyingNullableVector2(super.x, super.y);

  factory NotifyingNullableVector2.fromNullableVector2(
      NullableVector2? nullableVector2) {
    return NotifyingNullableVector2(nullableVector2?.x, nullableVector2?.y);
  }

  @override
  void operator []=(int i, double? v) {
    super[i] = v;
    notifyListeners();
  }

  @override
  void setFrom(NullableVector2? other) {
    super.setFrom(other);
    notifyListeners();
  }
}
