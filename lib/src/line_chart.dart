import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../simple_line_chart.dart';
import 'axis_labeller.dart';
import 'legend.dart';
import 'line_chart_data_series.dart';
import 'line_chart_grid.dart';
import 'line_chart_selection.dart';
import 'selection_model.dart';
import 'style.dart';
import 'text_painter.dart';
import 'x_axis.dart';
import 'y_axis.dart';

class LineChartController {
  late final Function()? _onSelectionChanged;
  SelectionModel? _selectionModel;

  LineChartController({Function()? onSelectionChanged}) {
    this._onSelectionChanged = onSelectionChanged;
  }

  List<QualifiedDataPoint> get selection => _selectionModel?.selection ?? [];
  set selection(List<QualifiedDataPoint> newSelection) {
    final model = _selectionModel;
    if (model == null) {
      throw Exception(
          'Can\'t set selection before the component is initialized');
    }
    model.selection = newSelection;
  }

  void _selectionChanged(List<QualifiedDataPoint> selection) {
    Function()? onChanged = _onSelectionChanged;
    if (onChanged != null) {
      onChanged();
    }
  }
}

class LineChart extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;
  late final LineChartController controller;

  LineChart(
      {Key? key,
      required this.style,
      required this.data,
      LineChartController? controller})
      : super(key: key) {
    this.controller = controller ?? LineChartController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final children = <Widget>[];

      final legendHeight = _estimateLegendHeight(constraints.maxWidth);
      final bottomInset = _xAxisHeight(style.bottomAxisStyle) + legendHeight;

      var leftAxisWidth = 0.0;
      var rightAxisWidth = 0.0;
      final leftDatasets =
          data.datasetsOf(axisDependency: YAxisDependency.LEFT);
      final rightDatasets =
          data.datasetsOf(axisDependency: YAxisDependency.RIGHT);
      final topInset = _xAxisHeight(style.topAxisStyle);
      final verticalAxisInset = topInset + bottomInset;
      AxisLabeller? leftAxisLabeller = style.leftAxisStyle == null
          ? null
          : AxisLabeller(style, style.leftAxisStyle!, data, leftDatasets,
              AxisDimension.Y, constraints.maxHeight - verticalAxisInset);
      AxisLabeller? rightAxisLabeller = style.rightAxisStyle == null
          ? null
          : AxisLabeller(
              style,
              style.rightAxisStyle!,
              data,
              rightDatasets.isEmpty ? leftDatasets : rightDatasets,
              AxisDimension.Y,
              constraints.maxHeight - verticalAxisInset);
      if (leftAxisLabeller != null) {
        leftAxisWidth = leftAxisLabeller.width +
            leftAxisLabeller.axisStyle.labelInsets.left +
            leftAxisLabeller.axisStyle.labelInsets.right;
      }
      if (rightAxisLabeller != null) {
        rightAxisWidth = rightAxisLabeller.width +
            rightAxisLabeller.axisStyle.labelInsets.left +
            rightAxisLabeller.axisStyle.labelInsets.right;
      }
      AxisLabeller? topAxisLabeller = style.topAxisStyle == null
          ? null
          : AxisLabeller(
              style,
              style.topAxisStyle!,
              data,
              data.datasets,
              AxisDimension.X,
              constraints.maxWidth - leftAxisWidth - rightAxisWidth);

      AxisLabeller? bottomAxisLabeller = style.bottomAxisStyle == null
          ? null
          : AxisLabeller(
              style,
              style.bottomAxisStyle!,
              data,
              data.datasets,
              AxisDimension.X,
              constraints.maxWidth - leftAxisWidth - rightAxisWidth);
      if (leftAxisLabeller != null) {
        children.add(Positioned(
            left: 0,
            top: 0,
            width: leftAxisWidth,
            height: constraints.maxHeight,
            child: YAxis(
                style: leftAxisLabeller.axisStyle,
                labeller: leftAxisLabeller,
                side: YAxisSide.LEFT,
                labelOffset: topInset,
                data: data)));
      }
      if (rightAxisLabeller != null) {
        children.add(Positioned(
            left: constraints.maxWidth - rightAxisWidth,
            top: 0,
            width: rightAxisWidth,
            height: constraints.maxHeight,
            child: YAxis(
                style: rightAxisLabeller.axisStyle,
                labeller: rightAxisLabeller,
                side: YAxisSide.RIGHT,
                labelOffset: topInset,
                data: data)));
      }
      if (topAxisLabeller != null) {
        children.add(Positioned(
            left: 0,
            top: 0,
            width: constraints.maxWidth,
            height: topInset,
            child: XAxis(
                style: topAxisLabeller.axisStyle,
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
                style: bottomAxisLabeller.axisStyle,
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
              controller: controller,
              xLabeller: bottomAxisLabeller ?? topAxisLabeller!,
              yLabeller: leftAxisLabeller ?? rightAxisLabeller!)));
      children.add(Positioned(
          left: leftAxisWidth,
          top: constraints.maxHeight - legendHeight,
          width: constraints.maxWidth - leftAxisWidth - rightAxisWidth,
          height: legendHeight,
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
      : _labelHeight(style) + style.labelInsets.bottom + style.labelInsets.top;

  double _estimateLegendHeight(double maxWidth) {
    double height = style.legendStyle.heightInsets;
    double lineHeight = 0;
    double lineOffset = 0;
    data.datasets.forEach((dataset) {
      final painter =
          createTextPainter(style.legendStyle.textStyle, dataset.label);
      if (lineOffset > 0 && painter.width + lineOffset > maxWidth) {
        height += lineHeight;
        lineOffset = 0;
        lineHeight = 0;
      }
      lineHeight =
          max(painter.height + (style.legendStyle.borderSize * 2), lineHeight);
      lineOffset += painter.width + Legend.widthAroundText(style.legendStyle);
    });
    height += lineHeight;
    return height;
  }

  double _labelHeight(AxisStyle? style) {
    if (style == null) {
      return 0;
    }
    return createTextPainter(style.textStyle, 'SAMPLE').height;
  }
}

class _ChartArea extends StatefulWidget {
  final LineChartData data;
  final LineChartStyle style;
  final LineChartController controller;
  final AxisLabeller xLabeller;
  final AxisLabeller yLabeller;

  const _ChartArea(
      {Key? key,
      required this.style,
      required this.data,
      required this.controller,
      required this.xLabeller,
      required this.yLabeller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChartAreaState();
  }
}

class _ChartAreaState extends State<_ChartArea> {
  SelectionModel? _selectionModel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return ChangeNotifierProvider(
        create: (context) {
          _selectionModel = SelectionModel(widget.style, widget.data, size);
          _selectionModel?.addListener(_onSelectionChanged);
          widget.controller._selectionModel = _selectionModel;
          return _selectionModel!;
        },
        builder: (context, child) => GestureDetector(
            onTapUp: (details) =>
                _selectionModel?.onTapUp(details.localPosition),
            onHorizontalDragStart: (details) =>
                _selectionModel?.onDrag(details.localPosition),
            onHorizontalDragUpdate: (details) =>
                _selectionModel?.onDrag(details.localPosition),
            child: Container(
              width: size.width,
              height: size.height,
              child: Stack(fit: StackFit.expand, children: [
                LineChartGrid(
                    style: (widget.style.topAxisStyle ??
                        widget.style.bottomAxisStyle)!,
                    xLabeller: widget.xLabeller,
                    yLabeller: widget.yLabeller),
                LineChartDataSeries(style: widget.style, data: widget.data),
                LineChartSelection(),
              ]),
            )),
      );
    });
  }

  @override
  void didUpdateWidget(covariant _ChartArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.style != widget.style ||
        oldWidget.xLabeller != widget.xLabeller ||
        oldWidget.yLabeller != widget.yLabeller) {
      setState(() {});
    }
  }

  void _onSelectionChanged() {
    widget.controller._selectionChanged(_selectionModel!.selection);
  }
}
