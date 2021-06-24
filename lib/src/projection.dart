import 'dart:ui';

import 'style.dart';
import 'line_chart_data.dart';
import 'extensions.dart';

class Projection {
  final LineChartStyle style;
  final Size size;
  final LineChartData data;
  late final double _yTransform;
  late final double minX;
  late final double minY;
  late final double maxX;
  late final double maxY;
  late final double xRange;
  late final double yRange;

  Projection(this.style, this.size, this.data) {
    _yTransform = 1.0;
    minX = data.minX;
    minY = _minY();
    maxX = data.maxX;
    maxY = _maxY();
    xRange = maxX - minX;
    yRange = maxY - minY;
  }

  Projection._(this.style, this.size, this.data, this.minX, this.minY,
      this.maxX, this.maxY, this.xRange, this.yRange, this._yTransform);

  Projection yTransform(double transform) {
    assert(transform >= 0 && transform <= 1.0);
    return Projection._(
        style, size, data, minX, minY, maxX, maxY, xRange, yRange, transform);
  }

  Offset toPixel({required Offset data}) {
    var y =
        size.height - (((data.dy - minY) / yRange) * size.height) * _yTransform;
    var x = ((data.dx - minX) / xRange) * size.width;
    return Offset(x, y);
  }

  List<DataPoint> fromPixel({required Offset position}) {
    final dataX = ((position.dx / size.width) * xRange) + minX;
    return data.datasets
        .map((dataset) => _closestByX(dataset, dataX))
        .whereType<DataPoint>()
        .toList();
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

  DataPoint? _closestByX(Dataset dataset, double dataX) {
    double? distance;
    DataPoint? dataPoint;
    dataset.dataPoints.forEach((candidate) {
      final candidateDistance = candidate.x.difference(dataX);
      if (distance == null || candidateDistance < distance!) {
        distance = candidateDistance;
        dataPoint = candidate;
      }
    });
    return dataPoint;
  }
}
