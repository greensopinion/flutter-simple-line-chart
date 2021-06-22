import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

import 'line_chart_data.dart';

enum AxisDimension { X, Y }

class AxisLabeller {
  final AxisStyle style;
  final LineChartData data;
  final AxisDimension axis;
  final double length;
  List<LabelPoint>? _labelPoints;

  AxisLabeller(this.style, this.data, this.axis, this.length);

  double get fontSize => style.textStyle.fontSize ?? AxisStyle.defaultFontSize;
  double get spacing => fontSize;
  double get width => labelPoints().map((e) => e.width).reduce(max);

  List<LabelPoint> labelPoints() {
    if (data.datasets.isEmpty || data.datasets.first.dataPoints.length < 2) {
      return [];
    }
    if (_labelPoints == null) {
      final labels = _labelPainter(data.datasets.first.dataPoints).toList();
      final labelSize = labels.map((e) => _textSize(e)).reduce(max);
      final labelSizeWithSpacing = labelSize + spacing;
      final labelCount = min(style.maxLabels, length ~/ labelSizeWithSpacing);
      if (axis == AxisDimension.X) {
        final interval =
            (data.datasets.first.dataPoints.length / labelCount).ceil();
        _labelPoints = labels
            .asMap()
            .entries
            .where((e) => (e.key % interval) == 0)
            .map((e) => LabelPoint(
                style.labelProvider(e.value.dataPoint),
                _textSize(e.value),
                e.value.painter.width,
                _centerX(e.value.dataPoint)))
            .toList();
      } else {
        var minY = data.datasets
            .map((dataset) => dataset.dataPoints.map((p) => p.y).reduce(min))
            .reduce(min);
        var maxY = data.datasets
            .map((dataset) => dataset.dataPoints.map((p) => p.y).reduce(max))
            .reduce(max);
        if (style.valueMargin != null) {
          minY -= style.valueMargin!;
          maxY += style.valueMargin!;
        }
        if (style.absoluteMin != null) {
          minY = style.absoluteMin!;
        }
        if (style.absoluteMax != null) {
          maxY = style.absoluteMax!;
        }
        minY = minY.floor().toDouble();
        maxY = maxY.ceil().toDouble();
        final range = minY.difference(maxY);
        final interval = (minY.difference(maxY) / labelCount).ceil();
        _labelPoints = <LabelPoint>[];
        for (var labelY = minY; labelY <= maxY; labelY += interval) {
          final text = style.labelProvider(DataPoint(x: 0, y: labelY));
          final painter = _createPainter(text);

          final offset = labelY.difference(minY);
          final center = offset / range * length;
          _labelPoints!.add(
              LabelPoint(text, painter.height, painter.width, length - center));
        }
      }
    }
    return _labelPoints!;
  }

  Iterable<_PainterPoint> _labelPainter(Iterable<DataPoint> points) => points
      .map((p) => _PainterPoint(p, _createPainter(style.labelProvider(p))));

  TextPainter _createPainter(String text) => TextPainter(
      text: TextSpan(style: style.textStyle, text: text),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr)
    ..layout();

  double _centerX(DataPoint point) {
    final first = data.datasets.first.dataPoints.first;
    final last = data.datasets.first.dataPoints.last;
    final range = last.x.difference(first.x);
    final offset = first.x.difference(point.x);
    return offset / range * length;
  }

  double _textSize(_PainterPoint e) =>
      (axis == AxisDimension.Y) ? e.painter.height : e.painter.width;
}

extension _PainterExtension on Iterable<DataPoint> {}

class LabelPoint {
  final String text;
  final double size;
  final double center;
  final double width;

  LabelPoint(this.text, this.size, this.width, this.center);

  double get offset => center - (size / 2);

  double get farEdge => center + (size / 2);
}

class _PainterPoint {
  final DataPoint dataPoint;
  final TextPainter painter;

  _PainterPoint(this.dataPoint, this.painter);
}

extension _DoubleExtension on double {
  double difference(double other) {
    if (other < 0 && this > 0 || other > 0 && this < 0) {
      return (other.abs() + this.abs()).abs();
    }
    return (other.abs() - this.abs()).abs();
  }
}
