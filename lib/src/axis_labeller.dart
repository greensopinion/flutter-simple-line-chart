import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

import 'line_chart_data.dart';

class AxisLabeller {
  final AxisStyle style;

  AxisLabeller(this.style);

  double largestLabel(Iterable<DataPoint> dataPoints) {
    return dataPoints.map((point) {
      final text = style.labelProvider(point);
      final painter = _createPainter(text);
      return painter.width;
    }).reduce(max);
  }

  TextPainter _createPainter(String text) => TextPainter(
      text: TextSpan(style: style.textStyle, text: text),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr)
    ..layout();
}
