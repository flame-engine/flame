import 'dart:ui';
import 'command.dart';

/// canvas.drawLine()
class LineCommand extends CanvasCommand {
  LineCommand(this.p1, this.p2, this.paint);
  final Offset p1;
  final Offset p2;
  final Paint? paint;

  @override
  bool equals(LineCommand other) {
    return eq(p1, other.p1) && eq(p2, other.p2) && eq(paint, other.paint);
  }

  @override
  String toString() {
    return 'drawLine(${repr(p1)}, ${repr(p2)}, ${repr(paint)})';
  }
}
