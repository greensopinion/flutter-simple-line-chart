import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/line_chart_grid.dart';
import 'package:simple_line_chart/src/style.dart';
import 'package:simple_line_chart/src/x_axis.dart';

import '../simple_line_chart.dart';
import 'legend.dart';

class LineChart extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  const LineChart({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (style.topAxisStyle != null) {
      children.add(XAxis(style: style.topAxisStyle!, data: data));
    }
    children.add(Expanded(child: Stack(children: [LineChartGrid()])));
    if (style.bottomAxisStyle != null) {
      children.add(XAxis(style: style.bottomAxisStyle!, data: data));
    }
    children.add(Legend(style: style, data: data));
    return Column(children: children);
  }
}
