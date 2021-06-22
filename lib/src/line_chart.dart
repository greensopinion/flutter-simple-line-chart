import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/line_chart_grid.dart';
import 'package:simple_line_chart/src/style.dart';
import 'package:simple_line_chart/src/x_axis.dart';
import 'package:simple_line_chart/src/y_axis.dart';

import '../simple_line_chart.dart';
import 'axis_labeller.dart';
import 'legend.dart';
import 'line_chart_data_series.dart';

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
      var leftAxisWidth = 0.0;
      var rightAxisWidth = 0.0;
      AxisLabeller? leftAxisLabeller = style.leftAxisStyle == null
          ? null
          : AxisLabeller(style.leftAxisStyle!, data, AxisDimension.Y,
              constraints.maxHeight - verticalAxisInset);
      AxisLabeller? rightAxisLabeller = style.rightAxisStyle == null
          ? null
          : AxisLabeller(style.rightAxisStyle!, data, AxisDimension.Y,
              constraints.maxHeight - verticalAxisInset);
      if (leftAxisLabeller != null) {
        leftAxisWidth = leftAxisLabeller.width +
            leftAxisLabeller.style.labelInsets.left +
            leftAxisLabeller.style.labelInsets.right;
        children.add(Positioned(
            left: 0,
            top: 0,
            width: leftAxisWidth,
            height: constraints.maxHeight,
            child: YAxis(
                style: leftAxisLabeller.style,
                labeller: leftAxisLabeller,
                side: YAxisSide.LEFT,
                labelOffset: topInset,
                data: data)));
      }
      if (rightAxisLabeller != null) {
        rightAxisWidth = rightAxisLabeller.width +
            rightAxisLabeller.style.labelInsets.left +
            rightAxisLabeller.style.labelInsets.right;
        children.add(Positioned(
            left: constraints.maxWidth - rightAxisWidth,
            top: 0,
            width: rightAxisWidth,
            height: constraints.maxHeight,
            child: YAxis(
                style: rightAxisLabeller.style,
                labeller: rightAxisLabeller,
                side: YAxisSide.RIGHT,
                labelOffset: topInset,
                data: data)));
      }
      AxisLabeller? topAxisLabeller = style.topAxisStyle == null
          ? null
          : AxisLabeller(style.topAxisStyle!, data, AxisDimension.X,
              constraints.maxWidth - leftAxisWidth - rightAxisWidth);

      AxisLabeller? bottomAxisLabeller = style.bottomAxisStyle == null
          ? null
          : AxisLabeller(style.bottomAxisStyle!, data, AxisDimension.X,
              constraints.maxWidth - leftAxisWidth - rightAxisWidth);
      if (topAxisLabeller != null) {
        children.add(Positioned(
            left: 0,
            top: 0,
            width: constraints.maxWidth,
            height: topInset,
            child: XAxis(
                style: topAxisLabeller.style,
                labeller: topAxisLabeller,
                labelOffset: leftAxisWidth,
                data: data)));
      }
      if (bottomAxisLabeller != null) {
        children.add(Positioned(
            left: 0,
            top: constraints.maxHeight - bottomInset,
            width: constraints.maxWidth,
            height: topInset,
            child: XAxis(
                style: bottomAxisLabeller.style,
                labeller: bottomAxisLabeller,
                labelOffset: leftAxisWidth,
                data: data)));
      }
      children.add(Positioned(
          left: leftAxisWidth,
          top: topInset,
          width: constraints.maxWidth - leftAxisWidth - rightAxisWidth,
          height: constraints.maxHeight - topInset - bottomInset,
          child: _ChartArea(
              data: data,
              style: style,
              xLabeller: bottomAxisLabeller ?? topAxisLabeller!,
              yLabeller: leftAxisLabeller ?? rightAxisLabeller!)));
      children.add(Positioned(
          left: leftAxisWidth,
          top: constraints.maxHeight - legendHeight,
          width: constraints.maxWidth - leftAxisWidth - rightAxisWidth,
          height: topInset,
          child: Legend(style: style, data: data)));
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Stack(children: children),
      );
    });
  }

  double _xAxisHeight(AxisStyle? style) => style == null
      ? 0.0
      : style.fontSize + style.labelInsets.bottom + style.labelInsets.top;

  double _legendHeight() => style.legendStyle.height;
}

class _ChartArea extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;
  final AxisLabeller xLabeller;
  final AxisLabeller yLabeller;

  const _ChartArea(
      {Key? key,
      required this.style,
      required this.data,
      required this.xLabeller,
      required this.yLabeller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Stack(fit: StackFit.expand, children: [
          LineChartGrid(
              style: (style.topAxisStyle ?? style.bottomAxisStyle)!,
              xLabeller: xLabeller,
              yLabeller: yLabeller),
          LineChartDataSeries(style: style, data: data)
        ]),
      );
    });
  }
}
