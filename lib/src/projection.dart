import 'dart:ui';

import 'style.dart';
import 'line_chart_data.dart';

class Projection {
  final LineChartStyle style;
  final Size size;
  final LineChartData data;
  late final double minX;
  late final double minY;
  late final double maxX;
  late final double maxY;
  late final double xRange;
  late final double yRange;

  Projection(this.style, this.size, this.data) {
    minX = data.minX;
    minY = _minY();
    maxX = data.maxX;
    maxY = _maxY();
    xRange = maxX - minX;
    yRange = maxY - minY;
  }

  Offset toPixel({required Offset data}) {
    var y = size.height - ((data.dy - minY) / yRange) * size.height;
    var x = ((data.dx - minX) / xRange) * size.width;
    return Offset(x, y);
  }

  double _minY() {
    var min = data.minY;
    final valueMargin = _yValueMargin();
    if (valueMargin != null) {
      min -= valueMargin;
    }
    final valueAbsoluteMin = _yValueAbsoluteMin();
    if (valueAbsoluteMin != null && min > valueAbsoluteMin) {
      min = valueAbsoluteMin;
    }
    return min;
  }

  double _maxY() {
    var max = data.maxY;
    final valueMargin = _yValueMargin();
    if (valueMargin != null) {
      max += valueMargin;
    }
    return max;
  }

  double? _yValueMargin() =>
      style.leftAxisStyle?.valueMargin ?? style.rightAxisStyle?.valueMargin;
  double? _yValueAbsoluteMin() =>
      style.leftAxisStyle?.absoluteMin ?? style.rightAxisStyle?.absoluteMin;
}
