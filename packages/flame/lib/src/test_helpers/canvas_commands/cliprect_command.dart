import 'dart:ui';
import 'command.dart';

/// canvas.clipRect()
class ClipRectCommand extends CanvasCommand {
  ClipRectCommand(this.clipRect, this.clipOp, this.doAntiAlias);

  final Rect clipRect;
  final ClipOp clipOp;
  final bool doAntiAlias;

  @override
  bool equals(ClipRectCommand other) {
    return eq(clipRect, other.clipRect) &&
        clipOp == other.clipOp &&
        doAntiAlias == other.doAntiAlias;
  }

  @override
  String toString() {
    return 'clipRect(${repr(clipRect)}, clipOp=$clipOp, doAntiAlias=$doAntiAlias)';
  }
}
