import 'package:flutter/widgets.dart';

/// A small triangle pointing right when collapsed and down when expanded.
class const DisclosureTriangle({
  required final bool isExpanded,
  required final Color color,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _TrianglePainter(isExpanded: isExpanded, color: color),
    );
  }
}

class _TrianglePainter({
  required final bool isExpanded,
  required final Color color,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final path = isExpanded
        ? (Path()
            ..moveTo(-4, -2)
            ..lineTo(4, -2)
            ..lineTo(0, 3)
            ..close())
        : (Path()
            ..moveTo(-2, -4)
            ..lineTo(3, 0)
            ..lineTo(-2, 4)
            ..close());
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      isExpanded != old.isExpanded || color != old.color;
}
