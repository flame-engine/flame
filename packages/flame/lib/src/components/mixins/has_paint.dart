import 'dart:ui';

import '../../../components.dart';
import '../../palette.dart';

mixin HasPaint on BaseComponent {
  /// Use this to change the paint used (to apply tint or opacity).
  ///
  /// If not provided the default is full white (no tint).
  Paint paint = BasicPalette.white.paint();
}
