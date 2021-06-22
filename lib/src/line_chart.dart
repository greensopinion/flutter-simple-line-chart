import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/line_chart_grid.dart';
import 'package:simple_line_chart/src/style.dart';
import 'package:simple_line_chart/src/x_axis.dart';

import '../simple_line_chart.dart';
import 'axis_labeller.dart';
import 'legend.dart';

class LineChart extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  const LineChart({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final children = <Widget>[];
      AxisLabeller? topAxisLabeller;
      AxisLabeller? bottomAxisLabeller;
      if (style.topAxisStyle != null) {
        topAxisLabeller = AxisLabeller(style.topAxisStyle!, data, constraints);
        children.add(XAxis(
            style: style.topAxisStyle!, labeller: topAxisLabeller, data: data));
      }
      if (style.bottomAxisStyle != null) {
        bottomAxisLabeller =
            AxisLabeller(style.bottomAxisStyle!, data, constraints);
      }
      children.add(Expanded(
          child: Stack(fit: StackFit.expand, children: [
        LineChartGrid(
            style: (style.topAxisStyle ?? style.bottomAxisStyle)!,
            labeller: (topAxisLabeller ?? bottomAxisLabeller)!)
      ])));
      if (style.bottomAxisStyle != null) {
        children.add(XAxis(
            style: style.bottomAxisStyle!,
            labeller: bottomAxisLabeller!,
            data: data));
      }
      children.add(Legend(style: style, data: data));
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children);
    });
  }
}
