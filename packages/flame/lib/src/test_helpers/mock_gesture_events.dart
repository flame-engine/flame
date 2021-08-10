import 'package:flutter/gestures.dart';

import '../../extensions.dart';
import '../../game.dart';
import '../../input.dart';

TapDownInfo createTapDownEvent(
  Game game, {
  Offset? globalPosition,
  Offset? localPosition,
}) {
  return TapDownInfo.fromDetails(
    game,
    TapDownDetails(
      localPosition: localPosition ?? Offset.zero,
      globalPosition: globalPosition ?? Offset.zero,
    ),
  );
}
