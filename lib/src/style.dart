import 'package:flutter/material.dart';

import 'line_chart_data.dart';
import 'text_painter.dart';

class LineChartStyle {
  final LegendStyle? legendStyle;
  final List<DatasetStyle> datasetStyles;
  final AxisStyle? topAxisStyle;
  final AxisStyle? bottomAxisStyle;
  final AxisStyle? leftAxisStyle;
  final AxisStyle? rightAxisStyle;

  /// the selection label style, which when specified enables a data label
  /// when the chart is touched
  final SelectionLabelStyle? selectionLabelStyle;

  /// the duration of animations when rendering the chart
  final Duration? animationDuration;

  /// the style of the selection highlight
  late final HighlightStyle? highlightStyle;

  LineChartStyle(
      {required this.legendStyle,
      required this.datasetStyles,
      this.topAxisStyle,
      this.bottomAxisStyle,
      this.leftAxisStyle,
      this.rightAxisStyle,
      this.highlightStyle,
      this.selectionLabelStyle,
      this.animationDuration = const Duration(seconds: 1)}) {
    assert(topAxisStyle != null || bottomAxisStyle != null);
    assert(leftAxisStyle != null || rightAxisStyle != null);
  }

  factory LineChartStyle.fromTheme(BuildContext context,
      {List<Color>? datasetColors}) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText1 ?? theme.textTheme.bodyText2!;
    final fontHeight = createTextPainter(textStyle, 'SAMPLE').height;
    final lineColor = textStyle.color!.withOpacity(0.3);
    final datasetStyles = (datasetColors ?? _defaultDatasetColors())
        .map((c) => DatasetStyle(color: c))
        .toList();
    final legendInsets = EdgeInsets.only(top: fontHeight / 2);
    final highlight =
        HighlightStyle(color: _Colors.highlight, lineSize: _defaultLineSize);
    final selectionLabelStyle = SelectionLabelStyle(
      borderColor: lineColor,
      textStyle: textStyle,
      xAxisLabelProvider: (point) => _defaultLabelProvider(point.x),
      leftYAxisLabelProvider: (point) => _defaultLabelProvider(point.y),
      rightYAxisLabelProvider: (point) => _defaultLabelProvider(point.y),
    );

    return LineChartStyle(
        legendStyle: LegendStyle(
            borderColor: lineColor, textStyle: textStyle, insets: legendInsets),
        datasetStyles: datasetStyles,
        highlightStyle: highlight,
        topAxisStyle: AxisStyle(
            textStyle: textStyle,
            lineColor: lineColor,
            labelProvider: (point) => _defaultLabelProvider(point.x),
            labelInsets: EdgeInsets.only(bottom: fontHeight / 2)),
        bottomAxisStyle: AxisStyle(
            textStyle: textStyle,
            lineColor: lineColor,
            labelProvider: (point) => _defaultLabelProvider(point.x),
            labelInsets: EdgeInsets.only(top: fontHeight / 2)),
        leftAxisStyle: AxisStyle(
            textStyle: textStyle,
            labelInsets: EdgeInsets.only(right: fontHeight / 2),
            labelProvider: (point) => _defaultLabelProvider(point.y),
            lineColor: lineColor),
        rightAxisStyle: AxisStyle(
            textStyle: textStyle,
            labelInsets: EdgeInsets.only(left: fontHeight / 2),
            labelProvider: (point) => _defaultLabelProvider(point.y),
            lineColor: lineColor),
        selectionLabelStyle: selectionLabelStyle);
  }

  DatasetStyle datasetStyleOfIndex(int index) {
    if (index < 0 || index >= datasetStyles.length) {
      throw 'Expecting style for $index';
    }
    return datasetStyles[index];
  }

  LineChartStyle copyWith(
      {LegendStyle? legendStyle,
      List<DatasetStyle>? datasetStyles,
      AxisStyle? topAxisStyle,
      AxisStyle? bottomAxisStyle,
      AxisStyle? leftAxisStyle,
      AxisStyle? rightAxisStyle,
      SelectionLabelStyle? selectionLabelStyle,
      Duration? animationDuration,
      HighlightStyle? highlightStyle}) {
    return LineChartStyle(
        legendStyle: legendStyle ?? this.legendStyle,
        datasetStyles: datasetStyles ?? this.datasetStyles,
        animationDuration: animationDuration ?? this.animationDuration,
        bottomAxisStyle: bottomAxisStyle ?? this.bottomAxisStyle,
        leftAxisStyle: leftAxisStyle ?? this.leftAxisStyle,
        rightAxisStyle: rightAxisStyle ?? this.rightAxisStyle,
        topAxisStyle: topAxisStyle ?? this.topAxisStyle,
        selectionLabelStyle: selectionLabelStyle ?? this.selectionLabelStyle,
        highlightStyle: highlightStyle ?? this.highlightStyle);
  }

  /// Copies the style with the specified axes. Differs from [copyWith]
  /// in that unxpecified or null axes are not present in the copy.
  /// Useful for removing axes.
  LineChartStyle copyWithAxes(
      {AxisStyle? topAxisStyle,
      AxisStyle? bottomAxisStyle,
      AxisStyle? leftAxisStyle,
      AxisStyle? rightAxisStyle}) {
    return LineChartStyle(
        legendStyle: legendStyle,
        datasetStyles: datasetStyles,
        animationDuration: animationDuration,
        bottomAxisStyle: bottomAxisStyle,
        leftAxisStyle: leftAxisStyle,
        rightAxisStyle: rightAxisStyle,
        topAxisStyle: topAxisStyle,
        selectionLabelStyle: selectionLabelStyle,
        highlightStyle: highlightStyle);
  }

  LineChartStyle copyWithoutLegend() {
    return copyRemoving(legend: true);
  }

  /// Copies the style with the indicated elements removed.
  /// pass true to remove elements
  LineChartStyle copyRemoving(
      {legend = false,
      selectionLabel = false,
      bottomAxis = false,
      topAxis = false,
      leftAxis = false,
      rightAxis = false}) {
    return LineChartStyle(
        legendStyle: legend ? null : legendStyle,
        datasetStyles: datasetStyles,
        animationDuration: animationDuration,
        bottomAxisStyle: bottomAxis ? null : bottomAxisStyle,
        leftAxisStyle: leftAxis ? null : leftAxisStyle,
        rightAxisStyle: rightAxis ? null : rightAxisStyle,
        topAxisStyle: topAxis ? null : topAxisStyle,
        selectionLabelStyle: selectionLabel ? null : selectionLabelStyle,
        highlightStyle: highlightStyle);
  }

  /// Copies the style with the indicated axis removed.
  /// pass true to remove the named axis.
  LineChartStyle copyRemovingAxis(
      {bool left = false,
      bool right = false,
      bool top = false,
      bool bottom = false}) {
    return copyRemoving(
        leftAxis: left, rightAxis: right, topAxis: top, bottomAxis: bottom);
  }

  @override
  int get hashCode => Object.hash(
      legendStyle,
      Object.hashAll(datasetStyles),
      topAxisStyle,
      bottomAxisStyle,
      leftAxisStyle,
      rightAxisStyle,
      animationDuration,
      selectionLabelStyle,
      highlightStyle);

  @override
  bool operator ==(Object other) =>
      other is LineChartStyle &&
      other.legendStyle == legendStyle &&
      other.datasetStyles == datasetStyles &&
      other.topAxisStyle == topAxisStyle &&
      other.bottomAxisStyle == bottomAxisStyle &&
      other.leftAxisStyle == leftAxisStyle &&
      other.rightAxisStyle == rightAxisStyle &&
      other.selectionLabelStyle == selectionLabelStyle &&
      other.animationDuration == animationDuration &&
      other.highlightStyle == highlightStyle;
}

typedef LabelFunction = String Function(DataPoint);
typedef AxisValuePredicate = bool Function(double axisValue);

class AxisStyle {
  static final double defaultFontSize = _defaultFontSize;

  /// the maximum number of labels to display
  final int maxLabels;

  /// if specified, the number of labels to display
  final int? labelCount;

  /// when true, the first label is not shown
  final bool skipFirstLabel;

  /// when true, the last label is not shown
  final bool skipLastLabel;

  /// when true, labels are shown exactly on datapoints instead of
  /// at any interval.
  final bool labelOnDatapoints;

  /// when specified, labels must be placed on values that are multiples
  /// of the specified value. For example, [labelIncrementMultiples] = 1 would
  /// meke labels appear on whole values only.
  final int? labelIncrementMultiples;

  /// the function that provides a text label from a data point value
  final LabelFunction labelProvider;

  /// the style to use when rendering labels
  final TextStyle textStyle;

  /// when false, labels are not shown
  final bool drawLabels;

  /// insets to apply to the axis
  final EdgeInsets labelInsets;

  /// the axis line color
  final Color lineColor;

  /// the width of the axis line
  final double lineSize;

  /// if specified, constrains the chart so that
  /// the chart displays with this value as the lower bound.
  final double? absoluteMin;

  /// if specified, constrains the minimum chart area value
  /// when the [minimumRange] is applied.
  final double? clampedMin;

  /// if specified, constrains the chart so that
  /// the chart displays with this value as the upper bound.
  final double? absoluteMax;

  /// the margin to apply above the maximum value on the chart,
  /// in data point units.
  final double? marginAbove;

  /// the margin to apply below the minimum value on the chart,
  /// in data point units.
  final double? marginBelow;

  /// indicates whether to apply the [marginBelow] based on the minimum Y value
  /// in data point units.
  final AxisValuePredicate? applyMarginBelow;

  /// the minimum range that values occupy on the chart regardless
  /// of values in the series.
  final double? minimumRange;

  AxisStyle(
      {required this.textStyle,
      required this.labelInsets,
      required this.labelProvider,
      required this.lineColor,
      this.lineSize = _defaultLineSize,
      this.drawLabels = true,
      this.maxLabels = 20,
      this.labelCount,
      this.skipFirstLabel = false,
      this.skipLastLabel = false,
      this.labelOnDatapoints = false,
      this.labelIncrementMultiples,
      this.absoluteMin,
      this.clampedMin,
      this.absoluteMax,
      this.marginAbove,
      this.marginBelow,
      this.applyMarginBelow,
      this.minimumRange});

  double get fontSize => textStyle.fontSize ?? defaultFontSize;

  @override
  int get hashCode => Object.hash(
      maxLabels,
      labelCount,
      skipFirstLabel,
      skipLastLabel,
      labelOnDatapoints,
      labelIncrementMultiples,
      labelProvider,
      textStyle,
      drawLabels,
      labelInsets,
      lineColor,
      lineSize,
      absoluteMin,
      clampedMin,
      absoluteMax,
      marginAbove,
      marginBelow,
      applyMarginBelow,
      minimumRange);

  @override
  bool operator ==(Object other) =>
      other is AxisStyle &&
      other.maxLabels == maxLabels &&
      other.labelCount == labelCount &&
      other.skipFirstLabel == skipFirstLabel &&
      other.skipLastLabel == skipLastLabel &&
      other.labelOnDatapoints == labelOnDatapoints &&
      other.labelIncrementMultiples == labelIncrementMultiples &&
      other.labelProvider == labelProvider &&
      other.textStyle == textStyle &&
      other.drawLabels == drawLabels &&
      other.labelInsets == labelInsets &&
      other.lineColor == lineColor &&
      other.lineSize == lineSize &&
      other.absoluteMax == absoluteMax &&
      other.absoluteMin == absoluteMin &&
      other.clampedMin == clampedMin &&
      other.marginAbove == marginAbove &&
      other.marginBelow == marginBelow &&
      other.minimumRange == minimumRange &&
      other.applyMarginBelow == applyMarginBelow &&
      other.textStyle == textStyle;

  AxisStyle copyWith(
      {int? maxLabels,
      int? labelCount,
      bool? skipFirstLabel,
      bool? skipLastLabel,
      bool? labelOnDatapoints,
      int? labelIncrementMultiples,
      LabelFunction? labelProvider,
      TextStyle? textStyle,
      bool? drawLabels,
      EdgeInsets? labelInsets,
      Color? lineColor,
      double? lineSize,
      double? absoluteMin,
      double? clampedMin,
      double? absoluteMax,
      double? marginAbove,
      double? marginBelow,
      AxisValuePredicate? applyMarginBelow,
      double? minimumRange}) {
    return AxisStyle(
        textStyle: textStyle ?? this.textStyle,
        labelInsets: labelInsets ?? this.labelInsets,
        skipFirstLabel: skipFirstLabel ?? this.skipFirstLabel,
        skipLastLabel: skipLastLabel ?? this.skipLastLabel,
        labelOnDatapoints: labelOnDatapoints ?? this.labelOnDatapoints,
        labelIncrementMultiples:
            labelIncrementMultiples ?? this.labelIncrementMultiples,
        labelProvider: labelProvider ?? this.labelProvider,
        lineColor: lineColor ?? this.lineColor,
        lineSize: lineSize ?? this.lineSize,
        drawLabels: drawLabels ?? this.drawLabels,
        maxLabels: maxLabels ?? this.maxLabels,
        labelCount: labelCount ?? this.labelCount,
        absoluteMin: absoluteMin ?? this.absoluteMin,
        clampedMin: clampedMin ?? this.clampedMin,
        absoluteMax: absoluteMax ?? this.absoluteMax,
        marginAbove: marginAbove ?? this.marginAbove,
        marginBelow: marginBelow ?? this.marginBelow,
        applyMarginBelow: applyMarginBelow ?? this.applyMarginBelow,
        minimumRange: minimumRange ?? this.minimumRange);
  }
}

class LegendStyle {
  static final double defaultFontSize = _defaultFontSize;
  final Color borderColor;
  final TextStyle textStyle;
  final EdgeInsets insets;
  final borderSize = 1.0;

  LegendStyle(
      {required this.borderColor,
      required this.textStyle,
      required this.insets});

  double get fontSize => textStyle.fontSize ?? defaultFontSize;
  double get heightInsets => insets.top + insets.bottom + (borderSize * 2);

  LegendStyle copyWith(
      {Color? borderColor, TextStyle? textStyle, EdgeInsets? insets}) {
    return LegendStyle(
        borderColor: borderColor ?? this.borderColor,
        textStyle: textStyle ?? this.textStyle,
        insets: insets ?? this.insets);
  }

  @override
  int get hashCode => Object.hash(borderColor, textStyle, insets, borderSize);

  @override
  bool operator ==(Object other) =>
      other is LegendStyle &&
      other.borderSize == borderSize &&
      other.borderColor == borderColor &&
      other.insets == insets &&
      other.textStyle == textStyle;
}

/// a style for rendering a selection label
class SelectionLabelStyle {
  /// the function that provides a text label from a data point value
  /// for data points that have [YAxisDependency.LEFT]
  final LabelFunction? leftYAxisLabelProvider;

  /// the function that provides a text label from a data point value
  /// for data points that have [YAxisDependency.RIGHT]
  final LabelFunction? rightYAxisLabelProvider;

  /// the function that provides a text label from a data point value
  /// for the x axis
  final LabelFunction? xAxisLabelProvider;

  /// the text style of the selection label
  final TextStyle textStyle;

  /// the border line color
  final Color borderColor;

  /// the width of the border line
  final borderSize = 1.0;

  SelectionLabelStyle(
      {this.leftYAxisLabelProvider,
      this.rightYAxisLabelProvider,
      this.xAxisLabelProvider,
      required this.textStyle,
      required this.borderColor});

  SelectionLabelStyle copyWith(
      {LabelFunction? leftYAxisLabelProvider,
      LabelFunction? rightYAxisLabelProvider,
      LabelFunction? xAxisLabelProvider,
      TextStyle? textStyle,
      Color? borderColor}) {
    return SelectionLabelStyle(
      leftYAxisLabelProvider:
          leftYAxisLabelProvider ?? this.leftYAxisLabelProvider,
      rightYAxisLabelProvider:
          rightYAxisLabelProvider ?? this.rightYAxisLabelProvider,
      xAxisLabelProvider: xAxisLabelProvider ?? this.xAxisLabelProvider,
      textStyle: textStyle ?? this.textStyle,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  /// provides a copy of the style removing the specified elements
  SelectionLabelStyle copyRemoving(
      {leftAxisLabel = false, rightAxisLabel = false, xAxisLabel = false}) {
    return SelectionLabelStyle(
        leftYAxisLabelProvider: leftAxisLabel ? null : leftYAxisLabelProvider,
        rightYAxisLabelProvider:
            rightAxisLabel ? null : rightYAxisLabelProvider,
        xAxisLabelProvider: xAxisLabel ? null : xAxisLabelProvider,
        textStyle: textStyle,
        borderColor: borderColor);
  }

  @override
  int get hashCode => Object.hash(borderColor, borderSize, xAxisLabelProvider,
      rightYAxisLabelProvider, leftYAxisLabelProvider);

  @override
  bool operator ==(Object other) =>
      other is SelectionLabelStyle &&
      other.borderSize == borderSize &&
      other.borderColor == borderColor &&
      other.xAxisLabelProvider == xAxisLabelProvider &&
      other.rightYAxisLabelProvider == rightYAxisLabelProvider &&
      other.leftYAxisLabelProvider == leftYAxisLabelProvider;
}

enum DatasetFillBaseline { ZERO, MIN_VALUE }

class DatasetStyle {
  static const double defaultLineSize = _defaultLineSize;
  final Color color;
  final double fillOpacity;
  final double lineSize;
  final double cubicIntensity;

  /// Determines whether fill should fill to 0 on the Y axis or the minimum value
  /// displayed in the chart.
  final DatasetFillBaseline fillBaseline;

  DatasetStyle(
      {required this.color,
      this.fillOpacity = 0.25,
      this.fillBaseline = DatasetFillBaseline.ZERO,
      this.lineSize = defaultLineSize,
      this.cubicIntensity = 0.2});

  DatasetStyle copyWith(
      {Color? color,
      double? fillOpacity,
      DatasetFillBaseline? fillBaseline,
      double? lineSize,
      double? cubicIntensity}) {
    return DatasetStyle(
        color: color ?? this.color,
        fillOpacity: fillOpacity ?? this.fillOpacity,
        fillBaseline: fillBaseline ?? this.fillBaseline,
        lineSize: lineSize ?? this.lineSize,
        cubicIntensity: cubicIntensity ?? this.cubicIntensity);
  }

  @override
  int get hashCode =>
      Object.hash(color, lineSize, fillOpacity, fillBaseline, cubicIntensity);

  @override
  bool operator ==(Object other) =>
      other is DatasetStyle &&
      other.color == color &&
      other.lineSize == lineSize &&
      other.fillOpacity == fillOpacity &&
      other.fillBaseline == fillBaseline &&
      other.cubicIntensity == cubicIntensity;
}

class HighlightStyle {
  final Color color;
  final double lineSize;
  final bool vertical;
  final bool horizontal;

  HighlightStyle(
      {required this.color,
      this.lineSize = _defaultLineSize,
      this.vertical = true,
      this.horizontal = true});

  HighlightStyle copyWith(
      {Color? color, double? lineSize, bool? vertical, bool? horizontal}) {
    return HighlightStyle(
        color: color ?? this.color,
        lineSize: lineSize ?? this.lineSize,
        vertical: vertical ?? this.vertical,
        horizontal: horizontal ?? this.horizontal);
  }

  @override
  int get hashCode => Object.hash(color, lineSize, vertical, horizontal);

  @override
  bool operator ==(Object other) =>
      other is HighlightStyle &&
      other.color == color &&
      other.lineSize == lineSize &&
      other.vertical == vertical &&
      other.horizontal == horizontal;
}

List<Color> _defaultDatasetColors() =>
    [_Colors.primary, _Colors.secondary, _Colors.tertiary];

class _Colors {
  static final _opaque = 0xff;
  static final Color primary = Color.fromARGB(_opaque, 88, 153, 218);
  static final Color secondary = Color.fromARGB(_opaque, 232, 116, 69);
  static final Color tertiary = Color.fromARGB(_opaque, 25, 169, 121);
  static final Color highlight = Color.fromARGB(_opaque, 242, 155, 29);
}

String _defaultLabelProvider(double v) => v.toStringAsFixed(0);

const _defaultLineSize = 1.0;
const _defaultFontSize = 12.0;
