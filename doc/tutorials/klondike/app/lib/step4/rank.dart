import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'klondike_game.dart';

@immutable
class Rank {
  factory Rank.fromInt(int value) {
    assert(
      value >= 1 && value <= 13,
      'value is outside of the bounds of what a rank can be',
    );
    return _singletons[value - 1];
  }

  Rank._(
    this.value,
    this.label,
    double x1,
    double y1,
    double x2,
    double y2,
    double w,
    double h,
  )   : redSprite = klondikeSprite(x1, y1, w, h),
        blackSprite = klondikeSprite(x2, y2, w, h);

  final int value;
  final String label;
  final Sprite redSprite;
  final Sprite blackSprite;

  static final List<Rank> _singletons = [
    Rank._(1, 'A', 335, 164, 789, 161, 120, 129),
    Rank._(2, '2', 20, 19, 15, 322, 83, 125),
    Rank._(3, '3', 122, 19, 117, 322, 80, 127),
    Rank._(4, '4', 213, 12, 208, 315, 93, 132),
    Rank._(5, '5', 314, 21, 309, 324, 85, 125),
    Rank._(6, '6', 419, 17, 414, 320, 84, 129),
    Rank._(7, '7', 509, 21, 505, 324, 92, 128),
    Rank._(8, '8', 612, 19, 607, 322, 78, 127),
    Rank._(9, '9', 709, 19, 704, 322, 84, 130),
    Rank._(10, '10', 810, 20, 805, 322, 137, 127),
    Rank._(11, 'J', 15, 170, 469, 167, 56, 126),
    Rank._(12, 'Q', 92, 168, 547, 165, 132, 128),
    Rank._(13, 'K', 243, 170, 696, 167, 92, 123),
  ];
}
