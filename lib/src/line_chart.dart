import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../simple_line_chart.dart';
import 'axis_labeller.dart';
import 'legend.dart';
import 'line_chart_data_series.dart';
import 'line_chart_grid.dart';
import 'line_chart_selection.dart';
import 'line_chart_selection_label.dart';
import 'selection_model.dart';
import 'text_painter.dart';
import 'x_axis.dart';
import 'y_axis.dart';

class LineChartController {
  late final Function()? _onSelectionChanged;
  List<QualifiedDataPoint> _previousSelection = [];
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
    if (onChanged != null && _previousSelection != selection) {
      _previousSelection = selection.toList();
      onChanged();
    }
  }
}

class LineChart extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;
  final double seriesHeight;
  final EdgeInsets padding;
  late final LineChartController controller;

  LineChart(
      {Key? key,
      required this.style,
      required this.data,
      required this.seriesHeight,
      EdgeInsets? padding = const EdgeInsets.only(left: 10, right: 10),
      LineChartController? controller})
      : this.padding = padding ?? EdgeInsets.zero,
        super(key: key) {
    this.controller = controller ?? LineChartController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final frame = BoxConstraints(
          maxHeight: seriesHeight - padding.top - padding.bottom,
          maxWidth: constraints.maxWidth - padding.left - padding.right);
      final children = <Widget>[];

      final bottomInset = _xAxisHeight(style.bottomAxisStyle);

      var leftAxisWidth = 0.0;
      var rightAxisWidth = 0.0;
      final topInset = _xAxisHeight(style.topAxisStyle);
      final verticalAxisInset = topInset + bottomInset;
      AxisLabeller? leftAxisLabeller = style.leftAxisStyle == null
          ? null
          : AxisLabeller(
              style,
              style.leftAxisStyle!,
              data,
              YAxisDependency.LEFT,
              AxisDimension.Y,
              frame.maxHeight - verticalAxisInset);
      AxisLabeller? rightAxisLabeller = style.rightAxisStyle == null
          ? null
          : AxisLabeller(
              style,
              style.rightAxisStyle!,
              data,
              YAxisDependency.RIGHT,
              AxisDimension.Y,
              frame.maxHeight - verticalAxisInset);
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
          : AxisLabeller(style, style.topAxisStyle!, data, null,
              AxisDimension.X, frame.maxWidth - leftAxisWidth - rightAxisWidth);

      AxisLabeller? bottomAxisLabeller = style.bottomAxisStyle == null
          ? null
          : AxisLabeller(style, style.bottomAxisStyle!, data, null,
              AxisDimension.X, frame.maxWidth - leftAxisWidth - rightAxisWidth);
      if (leftAxisLabeller != null) {
        children.add(Positioned(
            left: 0,
            top: 0,
            width: leftAxisWidth,
            height: frame.maxHeight - bottomInset,
            child: YAxis(
                style: leftAxisLabeller.axisStyle,
                labeller: leftAxisLabeller,
                side: YAxisSide.LEFT,
                labelOffset: topInset,
                data: data)));
      }
      if (rightAxisLabeller != null) {
        children.add(Positioned(
            left: frame.maxWidth - rightAxisWidth,
            top: 0,
            width: rightAxisWidth,
            height: frame.maxHeight - bottomInset,
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
            width: frame.maxWidth,
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
            top: frame.maxHeight - bottomInset,
            width: frame.maxWidth,
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
          width: frame.maxWidth - leftAxisWidth - rightAxisWidth,
          height: frame.maxHeight - topInset - bottomInset,
          child: _ChartArea(
              data: data,
              style: style,
              controller: controller,
              xLabeller: bottomAxisLabeller ?? topAxisLabeller!,
              yLabeller: leftAxisLabeller ?? rightAxisLabeller!)));
      final chartComponents = <Widget>[
        Container(
          width: constraints.maxWidth,
          height: seriesHeight,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
                left: padding.left,
                top: padding.top,
                width: frame.maxWidth,
                height: frame.maxHeight,
                child: Stack(clipBehavior: Clip.none, children: children))
          ]),
        )
      ];
      if (style.legendStyle != null) {
        chartComponents.add(Padding(
            padding: EdgeInsets.only(left: leftAxisWidth + padding.left),
            child: Legend(style: style, data: data)));
      }
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: chartComponents);
    });
  }

  double _xAxisHeight(AxisStyle? style) => style == null
      ? 0.0
      : _labelHeight(style) + style.labelInsets.bottom + style.labelInsets.top;

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

  bool _showSelectionLabel = false;

  bool get showSelectionLabel => _showSelectionLabel;
  set showSelectionLabel(bool newShow) {
    if (newShow != _showSelectionLabel) {
      setState(() {
        _showSelectionLabel = newShow;
      });
    }
  }

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
        builder: (context, child) {
          _selectionModel?.size = size;
          final children = [
            LineChartGrid(
                style: (widget.style.topAxisStyle ??
                    widget.style.bottomAxisStyle)!,
                xLabeller: widget.xLabeller,
                yLabeller: widget.yLabeller),
            LineChartDataSeries(style: widget.style, data: widget.data),
            LineChartSelection(),
          ];
          if (_showSelectionLabel &&
              widget.style.selectionLabelStyle != null &&
              (_selectionModel?.selection.isNotEmpty ?? false)) {
            children.add(Positioned(
                top: 8,
                left: 8,
                child: LineChartSelectionLabel(widget.data, widget.style)));
          }
          return GestureDetector(
              onTapDown: (details) {
                _selectionModel?.onTapDown(details.localPosition);
                showSelectionLabel = true;
              },
              onTapUp: (details) {
                _selectionModel?.onTapUp(details.localPosition);
                showSelectionLabel = false;
              },
              onHorizontalDragStart: (details) {
                _selectionModel?.onDrag(details.localPosition);
                showSelectionLabel = true;
              },
              onHorizontalDragUpdate: (details) =>
                  _selectionModel?.onDrag(details.localPosition),
              onHorizontalDragEnd: (details) => showSelectionLabel = false,
              child: Container(
                width: size.width,
                height: size.height,
                child: Stack(fit: StackFit.expand, children: children),
              ));
        },
      );
    });
  }

  @override
  void didUpdateWidget(covariant _ChartArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.style != widget.style ||
        oldWidget.xLabeller != widget.xLabeller ||
        oldWidget.yLabeller != widget.yLabeller ||
        oldWidget.controller != widget.controller) {
      setState(() {});
    }
  }

  void _onSelectionChanged() {
    widget.controller._selectionChanged(_selectionModel!.selection);
  }
}
