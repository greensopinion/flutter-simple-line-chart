import 'package:flutter/material.dart';

import 'axis_labeller.dart';
import 'line_chart_data.dart';
import 'style.dart';

class XAxis extends StatelessWidget {
  final AxisStyle style;
  final LineChartData data;
  final AxisLabeller labeller;
  final double labelOffset;

  const XAxis(
      {Key? key,
      required this.style,
      required this.labeller,
      required this.labelOffset,
      required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: style.labelInsets, child: _createLabels(context));
  }

  Widget _createLabels(BuildContext context) {
    if (data.datasets.isEmpty || data.datasets.first.dataPoints.length < 2) {
      return Container(height: style.textStyle.height);
    }
    final labelPoints = labeller.labelPoints();
    final children = labelPoints.map((p) {
      return Positioned(child: Text(p.text), left: p.offset + labelOffset);
    }).toList();
    return Container(
      width: labeller.length,
      height: labeller.fontSize,
      child: Stack(children: children),
    );
  }
}
