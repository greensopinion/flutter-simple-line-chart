import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/axis_labeller.dart';

import 'line_chart_data.dart';
import 'style.dart';

class XAxis extends StatelessWidget {
  final AxisStyle style;
  final LineChartData data;

  const XAxis({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: style.labelInsets, child: _createLabels(context));
  }

  Widget _createLabels(BuildContext context) {
    if (data.datasets.isEmpty || data.datasets.first.dataPoints.length < 2) {
      return Container(height: style.textStyle.height);
    }
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final fontSize = style.textStyle.fontSize ?? AxisStyle.defaultFontSize;
      final labelSpacing = fontSize;
      final labelWidth = labelSpacing +
          AxisLabeller(style).largestLabel(data.datasets.first.dataPoints);

      final labelCount = min(style.maxLabels, width ~/ labelWidth);
      final interval = data.datasets.first.dataPoints.length / labelCount;
      final labelPoints = data.datasets.first.dataPoints
          .asMap()
          .entries
          .where((e) => (e.key % interval) == 0)
          .map((e) => e.value)
          .toList();
      final first = data.datasets.first.dataPoints.first;
      final last = data.datasets.first.dataPoints.last;

      final children = labelPoints.map((p) {
        final centerOffset = ((last.x - p.x) / (last.x - first.x)) * width;
        return Positioned(
            child: Text(style.labelProvider(p)), left: centerOffset);
      }).toList();
      return Container(
        width: width,
        height: fontSize,
        child: Stack(children: children),
      );
    });
  }
}
