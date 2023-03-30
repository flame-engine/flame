import 'package:flutter/gestures.dart';

TapDownDetails createTapDownDetails({
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapDownDetails(
    localPosition: localPosition,
    globalPosition: globalPosition ?? Offset.zero,
  );
}

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
