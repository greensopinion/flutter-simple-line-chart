import 'package:flutter/material.dart';

import 'axis_labeller.dart';
import 'line_chart_data.dart';
import 'style.dart';

enum YAxisSide { LEFT, RIGHT }

class YAxis extends StatelessWidget {
  final AxisStyle style;
  final LineChartData data;
  final AxisLabeller labeller;
  final YAxisSide side;
  final double labelOffset;

  const YAxis(
      {Key? key,
      required this.style,
      required this.labeller,
      required this.labelOffset,
      required this.side,
      required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: style.labelInsets, child: _createLabels(context));
  }

  Widget _createLabels(BuildContext context) {
    if (data.datasets.isEmpty || data.datasets.first.dataPoints.length < 2) {
      return Container(width: 10);
    }
    return LayoutBuilder(builder: (context, constraints) {
      final labelPoints = labeller.labelPoints();
      final width = constraints.maxWidth;
      final children = labelPoints
          .map((p) => Positioned(
              child: Text(p.text, style: style.textStyle),
              left: (side == YAxisSide.RIGHT) ? 0 : width - p.width,
              top: p.offset + labelOffset))
          .toList();
      return Container(
        width: constraints.maxWidth,
        height: double.infinity,
        child: Stack(clipBehavior: Clip.none, children: children),
      );
    });
  }
}
