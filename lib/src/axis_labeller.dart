import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

import 'line_chart_data.dart';

class AxisLabeller {
  final AxisStyle style;
  final LineChartData data;
  final BoxConstraints constraints;
  late final double width;
  List<XLabelPoint>? _xLabelPoints;

  AxisLabeller(this.style, this.data, this.constraints) {
    width = constraints.maxWidth;
  }

  double get fontSize => style.textStyle.fontSize ?? AxisStyle.defaultFontSize;
  double get labelSpacing => fontSize;

  List<XLabelPoint> xLabelPoints() {
    if (data.datasets.isEmpty || data.datasets.first.dataPoints.length < 2) {
      return [];
    }
    if (_xLabelPoints == null) {
      final labels = _painter(data.datasets.first.dataPoints).toList();
      final labelWidth = labels.map((e) => e.painter.width).reduce(max);
      final labelWidthWithSpacing = labelWidth + fontSize;
      final labelCount = min(style.maxLabels, width ~/ labelWidthWithSpacing);
      final interval = data.datasets.first.dataPoints.length / labelCount;
      _xLabelPoints = labels
          .asMap()
          .entries
          .where((e) => (e.key % interval) == 0)
          .map((e) => XLabelPoint(
              e.value.dataPoint,
              style.labelProvider(e.value.dataPoint),
              e.value.painter.width,
              _centerOffset(e.value.dataPoint)))
          .toList();
    }
    return _xLabelPoints!;
  }

  double maxHeight(Iterable<DataPoint> dataPoints) {
    return _painter(dataPoints).map((e) => e.painter.height).reduce(max);
  }

  Iterable<_PainterPoint> _painter(Iterable<DataPoint> points) => points
      .map((p) => _PainterPoint(p, _createPainter(style.labelProvider(p))));

  TextPainter _createPainter(String text) => TextPainter(
      text: TextSpan(style: style.textStyle, text: text),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr)
    ..layout();

  double _centerOffset(DataPoint point) {
    final first = data.datasets.first.dataPoints.first;
    final last = data.datasets.first.dataPoints.last;
    return ((last.x - point.x) / (last.x - first.x)) * width;
  }
}

extension _PainterExtension on Iterable<DataPoint> {}

class XLabelPoint {
  final DataPoint dataPoint;
  final String text;
  final double width;
  final double centerOffset;

  XLabelPoint(this.dataPoint, this.text, this.width, this.centerOffset);

  double get offset => centerOffset - (width / 2);
  double get rightEdge => centerOffset + (width / 2);
}

class _PainterPoint {
  final DataPoint dataPoint;
  final TextPainter painter;

  _PainterPoint(this.dataPoint, this.painter);
}
