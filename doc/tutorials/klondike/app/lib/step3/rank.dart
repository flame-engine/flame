import 'package:flutter/foundation.dart';

@immutable
class Rank {
  factory Rank.of(int value) {
    assert(value >= 1 && value <= 13);
    return _singletons[value - 1];
  }

  const Rank._(this.value, this.label);

  static late final List<Rank> _singletons = [
    const Rank._(1, 'A'),
    const Rank._(2, '2'),
    const Rank._(3, '3'),
    const Rank._(4, '4'),
    const Rank._(5, '5'),
    const Rank._(6, '6'),
    const Rank._(7, '7'),
    const Rank._(8, '8'),
    const Rank._(9, '9'),
    const Rank._(10, '10'),
    const Rank._(11, 'J'),
    const Rank._(12, 'Q'),
    const Rank._(13, 'K'),
  ];

  final int value;
  final String label;
}
