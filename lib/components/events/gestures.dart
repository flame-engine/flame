import '../component.dart';
import 'package:flutter/gestures.dart';

mixin Tapeable on PositionComponent {
    void onTapCancel() {}
    void onTapDown(TapDownDetails details) {}
    void onTapUp(TapUpDetails details) {}
}
