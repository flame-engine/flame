import 'dart:ui';
import '../mock_canvas.dart';

/// This class encapsulates a single command that was issued to a [MockCanvas].
/// Most methods of [MockCanvas] will use a dedicated class derived from
/// [CanvasCommand] to store all the arguments and then match them against
/// the expected values.
///
/// Each subclass is expected to implement two methods:
///   - `equals()`, which compares the current object against another instance
///     of the same class; and
///   - `toString()`, which is used when printing error messages in case of a
///     mismatch.
///
/// Use helper function `eq()` to implement the first method, and `repr()` to
/// implement the second.
abstract class CanvasCommand {
  double tolerance = 1e-10;

  /// Return true if this command is equal to [other], up to the
  /// given absolute [tolerance]. The argument [other] is guaranteed
  /// to have the same type as the current command.
  bool equals(covariant CanvasCommand other);

  /// Helper function to check the equality of any two objects.
  bool eq(dynamic a, dynamic b) {
    if (a == null || b == null) {
      return true;
    }
    if (a is num && b is num) {
      return (a - b).abs() < tolerance;
    }
    if (a is Offset && b is Offset) {
      return eq(a.dx, b.dx) && eq(a.dy, b.dy);
    }
    if (a is List && b is List) {
      return a.length == b.length &&
          Iterable<int>.generate(a.length).every((i) => eq(a[i], b[i]));
    }
    if (a is Rect && b is Rect) {
      return eq(_rectAsList(a), _rectAsList(b));
    }
    if (a is RRect && b is RRect) {
      return eq(_rrectAsList(a), _rrectAsList(b));
    }
    if (a is Paint && b is Paint) {
      return eq(_paintAsList(a), _paintAsList(b));
    }
    return a == b;
  }

  /// Helper function to generate string representations of various
  /// components of a command.
  String repr(dynamic a) {
    if (a is num) {
      // A more compact stringification for a floating-point [a]: it avoids
      // printing ".0" at the end of round floating numbers.
      return (a == a.toInt()) ? a.toInt().toString() : a.toString();
    }
    if (a is Offset) {
      return 'Offset(${repr(a.dx)}, ${repr(a.dy)})';
    }
    if (a is List) {
      return a.map(repr).join(', ');
    }
    if (a is Rect) {
      return 'Rect(${repr(_rectAsList(a))})';
    }
    if (a is RRect) {
      return 'RRect(${repr(_rrectAsList(a))})';
    }
    if (a is Paint) {
      return 'Paint(${repr(_paintAsList(a))})';
    }
    return a.toString();
  }

  List<double> _rectAsList(Rect rect) {
    return [rect.left, rect.top, rect.right, rect.bottom];
  }

  List<double> _rrectAsList(RRect rect) {
    return [
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      rect.tlRadiusX,
      rect.tlRadiusY,
      rect.trRadiusX,
      rect.trRadiusY,
      rect.blRadiusX,
      rect.blRadiusY,
      rect.brRadiusX,
      rect.brRadiusY,
    ];
  }

  List _paintAsList(Paint paint) {
    return <dynamic>[
      paint.color,
      paint.blendMode,
      paint.style,
      paint.strokeWidth,
    ];
  }
}
