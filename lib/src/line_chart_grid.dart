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
      final rightProximity = (p.center - size.width).abs();
      final leftProximity = p.center;
      final margin = 4 * style.lineSize;
      if (rightProximity > margin && leftProximity > margin) {
        canvas.drawLine(
            Offset(p.center, 0), Offset(p.center, size.height), linePaint);
      }
    });
    yLabeller.labelPoints().forEach((p) {
      final bottomProximity = (p.center - size.height).abs();
      final topProximity = p.center;
      final margin = 4 * style.lineSize;
      if (bottomProximity > margin && topProximity > margin) {
        canvas.drawLine(
            Offset(0, p.center), Offset(size.width, p.center), linePaint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
