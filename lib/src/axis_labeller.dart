import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'line_chart_data.dart';
import 'style.dart';
import 'extensions.dart';
import 'text_painter.dart';

enum AxisDimension { X, Y }

class AxisLabeller {
  final AxisStyle style;
  final List<Dataset> datasets;
  final AxisDimension axis;
  final double length;
  List<LabelPoint>? _labelPoints;

  AxisLabeller(this.style, this.datasets, this.axis, this.length);

  double get fontSize => style.textStyle.fontSize ?? AxisStyle.defaultFontSize;
  double get spacing => fontSize;
  double get width =>
      labelPoints().isEmpty ? 0 : labelPoints().map((e) => e.width).reduce(max);
  double get labelHeight => labelPoints().isEmpty
      ? 0
      : labelPoints().map((e) => e.height).reduce(max);

  List<LabelPoint> labelPoints() {
    if (datasets.isEmpty || datasets.first.dataPoints.length < 2) {
      return [];
    }
    if (_labelPoints == null) {
      final labels = _labelPainter(datasets.first.dataPoints).toList();
      final labelSize =
          labels.isEmpty ? 0 : labels.map((e) => _textSize(e)).reduce(max);
      final labelSizeWithSpacing = labelSize + spacing;
      final labelCount = min(style.maxLabels, length ~/ labelSizeWithSpacing);
      if (axis == AxisDimension.X) {
        final interval = (datasets.first.dataPoints.length / labelCount).ceil();
        _labelPoints = labels
            .asMap()
            .entries
            .where((e) => (e.key % interval) == 0)
            .map((e) => LabelPoint(
                style.labelProvider(e.value.dataPoint),
                e.value.painter.width + _textWidthCorrection,
                e.value.painter.width + _textWidthCorrection,
                e.value.painter.height,
                _centerX(e.value.dataPoint)))
            .toList();
      } else {
        var minY = datasets
            .map((dataset) => dataset.dataPoints.map((p) => p.y).reduce(min))
            .reduce(min);
        var maxY = datasets
            .map((dataset) => dataset.dataPoints.map((p) => p.y).reduce(max))
            .reduce(max);
        if (style.marginAbove != null) {
          maxY += style.marginAbove!;
        }
        if (style.marginBelow != null) {
          minY -= style.marginBelow!;
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
          _labelPoints!.add(LabelPoint(text, painter.height, painter.width,
              painter.height, length - center));
        }
      }
    }
    return _labelPoints!;
  }

  Iterable<_PainterPoint> _labelPainter(Iterable<DataPoint> points) => points
      .map((p) => _PainterPoint(p, _createPainter(style.labelProvider(p))));

  TextPainter _createPainter(String text) =>
      createTextPainter(style.textStyle, text);

  double _centerX(DataPoint point) {
    final first = datasets.first.dataPoints.first;
    final last = datasets.first.dataPoints.last;
    final range = last.x.difference(first.x);
    final offset = first.x.difference(point.x);
    return offset / range * length;
  }

  double _textSize(_PainterPoint e) => (axis == AxisDimension.Y)
      ? e.painter.height
      : e.painter.width + _textWidthCorrection;
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
