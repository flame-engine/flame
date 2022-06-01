import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

abstract class TextBlock {
  double width = 0;
  double height = 0;
  Paint? backgroundPaint;
  Paint? borderPaint;
  List<Paint?>? borderPaintsLTRB;
  EdgeInsets? margin;
  EdgeInsets? padding;
  EdgeInsets? border;
  double borderRadius = 0;
  Rect? _rect;
  RRect? _rrect;

  @mustCallSuper
  void layout() {
    _rect = Rect.fromLTWH(0, 0, width, height);
    if (borderRadius != 0) {
      _rrect = RRect.fromRectAndRadius(_rect!, Radius.circular(borderRadius));
    }
  }

  void translate(double dx, double dy);

  @mustCallSuper
  void render(Canvas canvas) {
    if (borderRadius == 0) {
      if (backgroundPaint != null) {
        canvas.drawRect(_rect!, backgroundPaint!);
      }
      if (borderPaint != null) {
        canvas.drawRect(_rect!, borderPaint!);
      }
      if (borderPaintsLTRB != null) {
        final leftPaint = borderPaintsLTRB![0];
        final topPaint = borderPaintsLTRB![1];
        final rightPaint = borderPaintsLTRB![2];
        final bottomPaint = borderPaintsLTRB![3];
        final rbCorner = Offset(width, height);
        final rtCorner = Offset(0, height);
        final lbCorner = Offset(width, 0);
        if (leftPaint != null) {
          canvas.drawLine(Offset.zero, rtCorner, leftPaint);
        }
        if (topPaint != null) {
          canvas.drawLine(Offset.zero, lbCorner, topPaint);
        }
        if (rightPaint != null) {
          canvas.drawLine(lbCorner, rbCorner, rightPaint);
        }
        if (bottomPaint != null) {
          canvas.drawLine(rtCorner, rbCorner, bottomPaint);
        }
      }
    } else {
      if (backgroundPaint != null) {
        canvas.drawRRect(_rrect!, backgroundPaint!);
      }
      if (borderPaint != null) {
        canvas.drawRRect(_rrect!, borderPaint!);
      }
    }
  }
}
