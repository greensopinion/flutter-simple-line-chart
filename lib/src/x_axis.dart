import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/axis_labeller.dart';

import 'line_chart_data.dart';
import 'style.dart';

class XAxis extends StatelessWidget {
  final AxisStyle style;
  final LineChartData data;
  final AxisLabeller labeller;

  const XAxis(
      {Key? key,
      required this.style,
      required this.labeller,
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
    return LayoutBuilder(builder: (context, constraints) {
      final labelPoints = labeller.labelPoints();
      final children =
          labelPoints.where((p) => p.farEdge < labeller.length).map((p) {
        return Positioned(child: Text(p.text), left: p.offset);
      }).toList();
      return Container(
        width: labeller.length,
        height: labeller.fontSize,
        child: Stack(children: children),
      );
    });
  }
}
