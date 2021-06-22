import 'package:flutter/material.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

import 'axis_labeller.dart';

class LineChartGrid extends StatelessWidget {
  final AxisStyle style;
  final AxisLabeller labeller;

  const LineChartGrid({Key? key, required this.style, required this.labeller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(style, labeller));
  }
}

class _GridPainter extends CustomPainter {
  final AxisStyle style;
  final AxisLabeller labeller;
  _GridPainter(this.style, this.labeller);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineSize
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, linePaint);
    labeller.labelPoints().forEach((p) {
      canvas.drawLine(
          Offset(p.center, 0), Offset(p.center, size.height), linePaint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
