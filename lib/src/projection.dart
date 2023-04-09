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

  ProjectionDatasetMetrics leftMetrics() =>
      _leftMetrics.toProjectionDatasetMetrics();

  ProjectionDatasetMetrics rightMetrics() =>
      _rightMetrics.toProjectionDatasetMetrics();

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
    return data
        .datasetsOf(axisDependency: axisDependency)
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

class ProjectionDatasetMetrics {
  final double minY;
  final double maxY;
  final double rangeY;

  ProjectionDatasetMetrics._(this.minY, this.maxY, this.rangeY);
}

class _DatasetMetrics {
  LineChartStyle style;
  LineChartData data;
  YAxisDependency axisDependency;
  final double minX;
  final double maxX;
  late double _minY;
  late double _maxY;
  late double _yRange;
  late final double xRange;

  double get minY => _minY;
  double get maxY => _maxY;
  double get yRange => _yRange;

  _DatasetMetrics(
      this.style, this.data, this.minX, this.maxX, this.axisDependency) {
    _minY = _dataMinY().floorToDouble();
    _maxY = _dataMaxY().ceilToDouble();
    xRange = maxX - minX;
    _yRange = maxY.difference(minY);
    _applyMinimumRange();
  }

  double _dataMinY() {
    final absoluteMin = _axisStyle?.absoluteMin;
    if (absoluteMin != null) {
      return absoluteMin;
    }
    var min = data.minY(axisDependency);
    final valueMargin = _axisStyle?.marginBelow;
    if (valueMargin != null &&
        (_axisStyle?.applyMarginBelow?.call(min) ?? true)) {
      min -= valueMargin;
    }
    return min;
  }

  double _dataMaxY() {
    final absoluteMax = _axisStyle?.absoluteMax;
    if (absoluteMax != null) {
      return absoluteMax;
    }
    var max = data.maxY(axisDependency);
    final valueMargin = _axisStyle?.marginAbove;
    if (valueMargin != null) {
      max += valueMargin;
    }
    return max;
  }

  AxisStyle? get _axisStyle => axisDependency == YAxisDependency.LEFT
      ? style.leftAxisStyle
      : style.rightAxisStyle;

  void _applyMinimumRange() {
    final dataMinY = _minY;
    final minimumRange = _axisStyle?.minimumRange;
    if (minimumRange != null && yRange < minimumRange) {
      final difference = minimumRange - yRange;
      final margin = difference / 2.0;
      _maxY = (maxY + margin).ceil().toDouble();
      _minY = (minY - margin).floor().toDouble();
    }
    final intervalMultiple = _axisStyle?.labelIncrementMultiples;
    if (intervalMultiple != null) {
      final remainderPart = _minY % intervalMultiple;
      if (remainderPart != 0) {
        var minY = ((_minY ~/ intervalMultiple) * intervalMultiple).toDouble();
        _minY = min(minY, dataMinY);
      }
    }
    final absoluteMin = _axisStyle?.absoluteMin;
    if (absoluteMin != null && _minY < absoluteMin) {
      _minY = absoluteMin;
    }
    final absoluteMax = _axisStyle?.absoluteMax;
    if (absoluteMax != null && _maxY > absoluteMax) {
      _maxY = absoluteMax;
    }
    final clampedMin = _axisStyle?.clampedMin;
    if (clampedMin != null && _minY < clampedMin) {
      _minY = clampedMin;
    }
    _yRange = maxY.difference(minY);
  }

  ProjectionDatasetMetrics toProjectionDatasetMetrics() =>
      ProjectionDatasetMetrics._(minY, maxY, yRange);
}
