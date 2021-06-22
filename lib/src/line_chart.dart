import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/line_chart_grid.dart';
import 'package:simple_line_chart/src/style.dart';
import 'package:simple_line_chart/src/x_axis.dart';
import 'package:simple_line_chart/src/y_axis.dart';

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
      final topInset = _xAxisHeight(style.topAxisStyle);
      final legendHeight = _legendHeight();
      final bottomInset = _xAxisHeight(style.bottomAxisStyle) + legendHeight;
      final verticalAxisInset = topInset + bottomInset;
      AxisLabeller? leftAxisLabeller = style.leftAxisStyle == null
          ? null
          : AxisLabeller(style.leftAxisStyle!, data, AxisDimension.Y,
              constraints.maxHeight - verticalAxisInset);
      AxisLabeller? rightAxisLabeller = style.rightAxisStyle == null
          ? null
          : AxisLabeller(style.rightAxisStyle!, data, AxisDimension.Y,
              constraints.maxHeight - verticalAxisInset);
      if (leftAxisLabeller != null) {
        children.add(YAxis(
            style: leftAxisLabeller.style,
            labeller: leftAxisLabeller,
            side: YAxisSide.LEFT,
            labelOffset: topInset,
            data: data));
      }
      children.add(Expanded(child: _ChartSlab(data: data, style: style)));
      if (rightAxisLabeller != null) {
        children.add(YAxis(
            style: rightAxisLabeller.style,
            labeller: rightAxisLabeller,
            side: YAxisSide.RIGHT,
            labelOffset: topInset,
            data: data));
      }
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: children);
    });
  }

  double _xAxisHeight(AxisStyle? style) => style == null
      ? 0.0
      : style.fontSize + style.labelInsets.bottom + style.labelInsets.top;

  double _legendHeight() =>
      style.legendStyle.fontSize +
      style.legendStyle.insets.bottom +
      style.legendStyle.insets.top;
}

class _ChartSlab extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  const _ChartSlab({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final children = <Widget>[];
      AxisLabeller? topAxisLabeller = style.topAxisStyle == null
          ? null
          : AxisLabeller(
              style.topAxisStyle!, data, AxisDimension.X, constraints.maxWidth);
      ;
      AxisLabeller? bottomAxisLabeller = style.bottomAxisStyle == null
          ? null
          : AxisLabeller(style.bottomAxisStyle!, data, AxisDimension.X,
              constraints.maxWidth);
      if (topAxisLabeller != null) {
        children.add(XAxis(
            style: topAxisLabeller.style,
            labeller: topAxisLabeller,
            data: data));
      }
      children.add(Expanded(
          child: Stack(fit: StackFit.expand, children: [
        LineChartGrid(
            style: (style.topAxisStyle ?? style.bottomAxisStyle)!,
            labeller: (topAxisLabeller ?? bottomAxisLabeller)!)
      ])));
      if (bottomAxisLabeller != null) {
        children.add(XAxis(
            style: bottomAxisLabeller.style,
            labeller: bottomAxisLabeller,
            data: data));
      }
      children.add(Legend(style: style, data: data));
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children);
    });
  }
}
