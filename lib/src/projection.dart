import 'dart:math';
import 'dart:ui';

import 'extensions.dart';
import 'line_chart_data.dart';
import 'style.dart';

class Projection {
  final LineChartStyle style;
  final Size size;
  final LineChartData data;
  late final double _yTransform;
  late final _DatasetMetrics _leftMetrics;
  late final _DatasetMetrics _rightMetrics;

  Projection(this.style, this.size, this.data) {
    _yTransform = 1.0;
    final minX = _minX();
    final maxX = _maxX();
    _leftMetrics =
        _DatasetMetrics(style, data, minX, maxX, YAxisDependency.LEFT);
    _rightMetrics =
        _DatasetMetrics(style, data, minX, maxX, YAxisDependency.RIGHT);
  }

  Projection._(this.style, this.size, this.data, this._leftMetrics,
      this._rightMetrics, this._yTransform);

  Projection yTransform(double transform) {
    assert(transform >= 0 && transform <= 1.0);
    return Projection._(
        style, size, data, _leftMetrics, _rightMetrics, transform);
  }

  _DatasetMetrics _metrics(YAxisDependency axisDependency) =>
      axisDependency == YAxisDependency.LEFT ? _leftMetrics : _rightMetrics;

  Offset toPixel(
      {required YAxisDependency axisDependency, required Offset data}) {
    final metrics = _metrics(axisDependency);
    var y = size.height -
        (((data.dy - metrics.minY) / metrics.yRange) * size.height) *
            _yTransform;
    var x = ((data.dx - metrics.minX) / metrics.xRange) * size.width;
    return Offset(x, y);
  }

  List<QualifiedDataPoint> fromPixel({required Offset position}) {
    return _fromPixel(
            axisDependency: YAxisDependency.LEFT, position: position) +
        _fromPixel(axisDependency: YAxisDependency.RIGHT, position: position);
  }

  List<QualifiedDataPoint> _fromPixel(
      {required YAxisDependency axisDependency, required Offset position}) {
    final metrics = _metrics(axisDependency);
    final dataX = ((position.dx / size.width) * metrics.xRange) + metrics.minX;
    return data.datasets
        .map((dataset) {
          final point = _closestByX(dataset, dataX);
          if (point != null) {
            return QualifiedDataPoint(dataset, point);
          }
        })
        .whereType<QualifiedDataPoint>()
        .toList();
  }

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

  double _minX() {
    final values = data.datasets.map((e) => e.minX);
    return values.isEmpty ? 0 : values.reduce(min);
  }

  double _maxX() {
    final values = data.datasets.map((e) => e.maxX);
    return values.isEmpty ? 0 : values.reduce(max);
  }
}

class _DatasetMetrics {
  LineChartStyle style;
  LineChartData data;
  YAxisDependency axisDependency;
  final double minX;
  final double maxX;
  late final double minY;
  late final double maxY;
  late final double xRange;
  late final double yRange;

  _DatasetMetrics(
      this.style, this.data, this.minX, this.maxX, this.axisDependency) {
    minY = _minY();
    maxY = _maxY();
    xRange = maxX - minX;
    yRange = maxY - minY;
  }

  double _minY() {
    final absoluteMin = _axisStyle?.absoluteMin;
    if (absoluteMin != null) {
      return absoluteMin;
    }
    var min = data.minY(axisDependency);
    final valueMargin = _axisStyle?.valueMargin;
    if (valueMargin != null) {
      min -= valueMargin;
    }
    return min;
  }

  double _maxY() {
    final absoluteMax = _axisStyle?.absoluteMax;
    if (absoluteMax != null) {
      return absoluteMax;
    }
    var max = data.maxY(axisDependency);
    final valueMargin = _axisStyle?.valueMargin;
    if (valueMargin != null) {
      max += valueMargin;
    }
    return max;
  }

  AxisStyle? get _axisStyle => axisDependency == YAxisDependency.LEFT
      ? style.leftAxisStyle
      : style.rightAxisStyle;
}
