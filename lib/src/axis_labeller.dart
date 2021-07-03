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
  double get spacing => fontSize / 2.0;
  double get width =>
      labelPoints().isEmpty ? 0 : labelPoints().map((e) => e.width).reduce(max);
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
    if (datasets.isEmpty || datasets.first.dataPoints.length < 2) {
      return [];
    }
    final projection = Projection(style, Size(length, length), data);
    if (_labelPoints == null) {
      final labels = _labelPainter(datasets.first.dataPoints).toList();
      final labelSize =
          labels.isEmpty ? 0 : labels.map((e) => _textSize(e)).reduce(max);
      final labelSizeWithSpacing = labelSize + spacing;
      final labelCount = axisStyle.labelCount ??
          min(axisStyle.maxLabels, length ~/ labelSizeWithSpacing);
      if (labelCount == 0) {
        _labelPoints = [];
      } else if (axis == AxisDimension.X) {
        double minX = data.datasets.minX();
        double maxX = data.datasets.maxX();
        double range = minX.difference(maxX);
        _labelPoints = <LabelPoint>[];
        if (axisStyle.labelOnDatapoints) {
          final interval =
              (datasets.first.dataPoints.length / labelCount).ceil();
          datasets.first.dataPoints.asMap().forEach((index, point) {
            if (index % interval == 0) {
              _labelPoints!.add(_createXaxisLabelPoint(
                  projection, point, datasets.first.axisDependency));
            }
          });
        } else {
          final interval = (range / labelCount);
          if (interval > 0) {
            for (var labelX = minX; labelX <= maxX; labelX += interval) {
              _labelPoints!.add(_createXaxisLabelPoint(projection,
                  DataPoint(x: labelX, y: 0), datasets.first.axisDependency));
            }
          }
        }
      } else {
        final metrics = axisDependency == YAxisDependency.LEFT
            ? projection.leftMetrics()
            : projection.rightMetrics();

        final interval = (metrics.rangeY / labelCount);
        _labelPoints = <LabelPoint>[];
        if (interval > 0) {
          for (var labelY = metrics.minY;
              labelY <= metrics.maxY;
              labelY += interval) {
            if ((axisStyle.skipFirstLabel && labelY == metrics.minY) ||
                (axisStyle.skipLastLabel &&
                    (labelY + interval) > metrics.maxY)) {
              continue;
            }
            final text = axisStyle.labelProvider(DataPoint(x: 0, y: labelY));
            final painter = _createPainter(text);

            final center = projection.toPixel(
                axisDependency: datasets.first.axisDependency,
                data: Offset(0, labelY));
            _labelPoints!.add(LabelPoint(text, painter.height, painter.width,
                painter.height, center.dy));
          }
        }
      }
    }
    return _labelPoints!;
  }

  Iterable<_PainterPoint> _labelPainter(Iterable<DataPoint> points) => points
      .map((p) => _PainterPoint(p, _createPainter(axisStyle.labelProvider(p))));

  TextPainter _createPainter(String text) =>
      createTextPainter(axisStyle.textStyle, text);

  double _textSize(_PainterPoint e) => (axis == AxisDimension.Y)
      ? e.painter.height
      : e.painter.width + _textWidthCorrection;

  LabelPoint _createXaxisLabelPoint(
      Projection projection, DataPoint point, YAxisDependency axisDependency) {
    final text = axisStyle.labelProvider(point);
    final painter = _createPainter(text);

    final center = projection.toPixel(
        axisDependency: axisDependency, data: Offset(point.x, 0));
    return LabelPoint(text, painter.width + _textWidthCorrection,
        painter.width + _textWidthCorrection, painter.height, center.dx);
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

class _PainterPoint {
  final DataPoint dataPoint;
  final TextPainter painter;

  _PainterPoint(this.dataPoint, this.painter);
}
