import 'package:flutter/material.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

import 'axis_labeller.dart';

class LineChartGrid extends StatelessWidget {
  final AxisStyle style;
  final AxisLabeller xLabeller;
  final AxisLabeller yLabeller;

  const LineChartGrid(
      {Key? key,
      required this.style,
      required this.xLabeller,
      required this.yLabeller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(style, xLabeller, yLabeller));
  }
}

class _GridPainter extends CustomPainter {
  final AxisStyle style;
  final AxisLabeller xLabeller;
  final AxisLabeller yLabeller;
  _GridPainter(this.style, this.xLabeller, this.yLabeller);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineSize
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, linePaint);
    xLabeller.labelPoints().forEach((p) {
      canvas.drawLine(
          Offset(p.center, 0), Offset(p.center, size.height), linePaint);
    });
    yLabeller.labelPoints().forEach((p) {
      canvas.drawLine(
          Offset(0, p.center), Offset(size.width, p.center), linePaint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
