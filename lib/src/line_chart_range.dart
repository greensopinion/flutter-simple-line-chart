import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../simple_line_chart.dart';

class LineChartRange extends StatelessWidget {
  final RangeDataset dataset;
  final RangeDatasetStyle rangeStyle;
  final DatasetStyle style;

  const LineChartRange(
      {super.key,
      required this.dataset,
      required this.rangeStyle,
      required this.style});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: rangeStyle.height),
      child: CustomPaint(painter: _RangePainter(dataset, rangeStyle, style)));
}

class _RangePainter extends CustomPainter {
  final RangeDataset dataset;
  final RangeDatasetStyle rangeStyle;
  final DatasetStyle style;

  _RangePainter(this.dataset, this.rangeStyle, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset(0, 0) & size);
    final paint = Paint()
      ..color = style.color.withOpacity(style.fillOpacity)
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..strokeWidth = style.lineSize
      ..color = style.color
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
    final bounds = dataset.bounds;
    final boundsWidth = bounds.high - bounds.low;
    final availableWidth = size.width;
    for (final range in dataset.ranges) {
      final start = ((range.low - bounds.low) / boundsWidth * availableWidth);
      final end = ((range.high - bounds.low) / boundsWidth * availableWidth);
      if (dataset.gradientDistance > 0.0) {
        final fadeDistance =
            (dataset.gradientDistance / boundsWidth) * availableWidth;
        final fadeIn = Paint()
          ..shader = ui.Gradient.linear(
              Offset(start, rangeStyle.height / 2.0),
              Offset(start + fadeDistance, rangeStyle.height / 2.0),
              [paint.color.withOpacity(0.0), paint.color]);
        final fadeOut = Paint()
          ..shader = ui.Gradient.linear(
              Offset(end - fadeDistance, rangeStyle.height / 2.0),
              Offset(end, rangeStyle.height / 2.0),
              [paint.color, paint.color.withOpacity(0.0)]);

        canvas.drawRect(
            Rect.fromLTWH(start, 0.0, fadeDistance, rangeStyle.height), fadeIn);
        canvas.drawRect(
            Rect.fromLTWH(start + fadeDistance, 0.0,
                (end - start) - (fadeDistance * 2), rangeStyle.height),
            paint);
        canvas.drawRect(
            Rect.fromLTWH(
                end - fadeDistance, 0.0, fadeDistance, rangeStyle.height),
            fadeOut);
      } else {
        final rect = Rect.fromLTWH(start, 0.0, end - start, rangeStyle.height);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
