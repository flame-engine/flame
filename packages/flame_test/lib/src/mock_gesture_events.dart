import 'package:flutter/gestures.dart';

TapUpDetails createTapUpDetails({
  Offset? globalPosition,
  Offset? localPosition,
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) {
  return TapUpDetails(
    localPosition: localPosition,
    globalPosition: globalPosition ?? Offset.zero,
    kind: PointerDeviceKind.mouse,
  );
}
