import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'extensions.dart';
import 'line_chart_data.dart';
import 'projection.dart';
import 'style.dart';
import 'text_painter.dart';

enum AxisDimension { X, Y }

class AxisLabeller {
  final LineChartStyle style;
  final AxisStyle axisStyle;
  final LineChartData data;
  late final YAxisDependency axisDependency;
  final AxisDimension axis;
  final double length;
  List<LabelPoint>? _labelPoints;

  AxisLabeller(this.style, this.axisStyle, this.data,
      YAxisDependency? axisDependency, this.axis, this.length) {
    this.axisDependency = axisDependency ?? YAxisDependency.LEFT;
  }

  double get fontSize =>
      axisStyle.textStyle.fontSize ?? AxisStyle.defaultFontSize;
  double get spacing => fontSize / 3 * 4;
  double get width => labelPoints().isEmpty
      ? 0
      : labelPoints().map((e) => e.width).reduce(max).ceilToDouble();
  double get labelHeight => labelPoints().isEmpty
      ? 0
      : labelPoints().map((e) => e.height).reduce(max);

  List<LabelPoint> labelPoints() {
    var axisDependency = this.axisDependency;
    var datasets = data.datasetsOf(axisDependency: axisDependency);
    if (datasets.isEmpty) {
      axisDependency = YAxisDependency.LEFT;
      datasets = data.datasetsOf(axisDependency: axisDependency);
    }
    final dataSet = datasets.firstWhere((p) => p.dataPoints.length > 2,
        orElse: () => datasets.first);
    if (dataSet.dataPoints.length < 2) {
      return [];
    }
    final projection = Projection(style, Size(length, length), data);
    if (_labelPoints == null) {
      final longestLabel = _longestLabel(dataSet.dataPoints);
      final labelSize = _textSize(_createPainter(longestLabel));
      final labelSizeWithSpacing =
          labelSize + max(spacing, (labelSize / 4).ceilToDouble());
      final labelCount = axisStyle.labelCount ??
          min(axisStyle.maxLabels, length ~/ labelSizeWithSpacing);
      if (labelCount == 0) {
        _labelPoints = [];
      } else if (axis == AxisDimension.X) {
        double minX = data.datasets.minX();
        double maxX = data.datasets.maxX();
        double range = minX.difference(maxX);
        final labelPoints = <LabelPoint>[];
        if (axisStyle.labelOnDatapoints) {
          final interval = (dataSet.dataPoints.length / labelCount).ceil();
          dataSet.dataPoints.asMap().forEach((index, point) {
            if (index % interval == 0) {
              labelPoints.add(_createXaxisLabelPoint(
                  projection, point, dataSet.axisDependency));
            }
          });
        } else {
          final interval = (range / labelCount).round();
          if (interval > 0) {
            for (var labelX = minX; labelX <= maxX; labelX += interval) {
              labelPoints.add(_createXaxisLabelPoint(projection,
                  DataPoint(x: labelX, y: 0), dataSet.axisDependency));
            }
          }
        }
        _labelPoints = labelPoints;
      } else {
        final metrics = axisDependency == YAxisDependency.LEFT
            ? projection.leftMetrics()
            : projection.rightMetrics();

        final interval = _applyIntervalConstraints(metrics.rangeY / labelCount);
        final labelPoints = <LabelPoint>[];
        if (interval > 0) {
          List<double> labelValues = [];
          if (metrics.minY < 0 && metrics.maxY > 0) {
            for (var labelY = 0.0; labelY >= metrics.minY; labelY -= interval) {
              labelValues.insert(0, labelY);
            }
            for (var labelY = interval;
                labelY <= metrics.maxY;
                labelY += interval) {
              labelValues.add(labelY);
            }
            if (axisStyle.skipFirstLabel &&
                labelValues.isNotEmpty &&
                labelValues.first == metrics.minY) {
              labelValues.remove(0);
            }
            if (axisStyle.skipLastLabel &&
                labelValues.isNotEmpty &&
                labelValues.last == metrics.maxY) {
              labelValues.removeLast();
            }
          } else {
            for (var labelY = metrics.minY;
                labelY <= metrics.maxY;
                labelY += interval) {
              if ((axisStyle.skipFirstLabel && labelY == metrics.minY) ||
                  (axisStyle.skipLastLabel &&
                      (labelY + interval) > metrics.maxY)) {
                continue;
              }
              labelValues.add(labelY);
            }
          }
          for (var labelY in labelValues) {
            final text = axisStyle.labelProvider(DataPoint(x: 0, y: labelY));
            final painter = _createPainter(text);

            final center = projection.toPixel(
                axisDependency: dataSet.axisDependency,
                data: Offset(0, labelY));
            labelPoints.add(LabelPoint(text, painter.height, painter.width,
                painter.height, center.dy));
          }
        }
        _labelPoints = labelPoints;
      }
    }
    return _labelPoints!;
  }

  String _longestLabel(List<DataPoint> points) => points.isEmpty
      ? ''
      : _takeSelection(points)
          .map((p) => axisStyle.labelProvider(p))
          .reduce((a, b) => a.length > b.length ? a : b)
          .replaceAll(RegExp(r'[a-zA-Z0-9]'), 'E');

  Iterable<DataPoint> _takeSelection(List<DataPoint> points) {
    if (points.length < 10) {
      return points;
    }
    return points.take(2).toList() +
        [points[(points.length / 2).floor()]] +
        [points.last];
  }

  TextPainter _createPainter(String text) =>
      createTextPainter(axisStyle.textStyle, text);

  double _textSize(TextPainter painter) => (axis == AxisDimension.Y)
      ? painter.height
      : painter.width + _textWidthCorrection;

  LabelPoint _createXaxisLabelPoint(
      Projection projection, DataPoint point, YAxisDependency axisDependency) {
    final text = axisStyle.labelProvider(point);
    final painter = _createPainter(text);

    final center = projection.toPixel(
        axisDependency: axisDependency, data: Offset(point.x, 0));
    return LabelPoint(text, painter.width + _textWidthCorrection,
        painter.width + _textWidthCorrection, painter.height, center.dx);
  }

  double _applyIntervalConstraints(double interval) {
    final multiples = axisStyle.labelIncrementMultiples;
    if (multiples != null) {
      final remainderPart = interval % multiples;
      if (remainderPart > 0) {
        final wholePart = interval ~/ multiples;
        return ((wholePart + 1) * multiples).toDouble();
      }
    }
    return interval;
  }
}

extension _PainterExtension on Iterable<DataPoint> {}

class LabelPoint {
  final String text;
  final double size;
  final double center;
  late final double width;
  final double height;

  LabelPoint(this.text, this.size, this.width, this.height, this.center);

  double get offset => center - (size / 2);

  double get farEdge => center + (size / 2);
}

// not sure why, but TextPainter seems to calculate
// text width short by 2 pixels
const double _textWidthCorrection = 2;
