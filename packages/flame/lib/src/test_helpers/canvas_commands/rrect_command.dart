import 'dart:ui';
import 'command.dart';

/// canvas.drawRRect()
class RRectCommand extends CanvasCommand {
  RRectCommand(this.rrect, this.paint);
  final RRect rrect;
  final Paint? paint;

  @override
  bool equals(RRectCommand other) {
    return eq(rrect, other.rrect) && eq(paint, other.paint);
  }

  @override
  String toString() {
    return 'drawRRect(${repr(rrect)}, ${repr(paint)})';
  }
}
