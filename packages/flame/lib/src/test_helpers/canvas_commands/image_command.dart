import 'dart:ui';
import 'command.dart';

/// canvas.drawImage()
class ImageCommand extends CanvasCommand {
  final Offset offset;
  final Paint? paint;

  ImageCommand(this.offset, this.paint);

  @override
  bool equals(ImageCommand other) {
    return eq(offset, other.offset) && eq(paint, other.paint);
  }

  @override
  String toString() {
    return 'drawImage(image, ${repr(offset)}, ${repr(paint)})';
  }
}
