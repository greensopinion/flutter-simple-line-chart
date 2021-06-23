import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'line_chart_data.dart';

class LineChartStyle {
  final LegendStyle legendStyle;
  final List<DatasetStyle> datasetStyles;
  final AxisStyle? topAxisStyle;
  final AxisStyle? bottomAxisStyle;
  final AxisStyle? leftAxisStyle;
  final AxisStyle? rightAxisStyle;

  LineChartStyle(
      {required this.legendStyle,
      required this.datasetStyles,
      this.topAxisStyle,
      this.bottomAxisStyle,
      this.leftAxisStyle,
      this.rightAxisStyle}) {
    assert(topAxisStyle != null || bottomAxisStyle != null);
    assert(leftAxisStyle != null || rightAxisStyle != null);
  }

  factory LineChartStyle.fromTheme(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText1 ?? theme.textTheme.bodyText2!;
    final lineColor = textStyle.color!.withOpacity(0.3);
    final datasetStyles =
        _defaultDatasetColors().map((c) => DatasetStyle(color: c)).toList();
    final fontSize = textStyle.fontSize ?? LegendStyle.defaultFontSize;
    final legendInsets = EdgeInsets.only(top: fontSize);

    return LineChartStyle(
        legendStyle: LegendStyle(
            lineColor: lineColor, textStyle: textStyle, insets: legendInsets),
        datasetStyles: datasetStyles,
        topAxisStyle: AxisStyle(
            textStyle: textStyle,
            lineColor: lineColor,
            labelProvider: (point) => _defaultLabelProvider(point.x),
            labelInsets: EdgeInsets.only(bottom: fontSize / 2)),
        bottomAxisStyle: AxisStyle(
            textStyle: textStyle,
            lineColor: lineColor,
            labelProvider: (point) => _defaultLabelProvider(point.x),
            labelInsets: EdgeInsets.only(top: fontSize / 2)),
        leftAxisStyle: AxisStyle(
            textStyle: textStyle,
            labelInsets: EdgeInsets.only(right: fontSize / 2),
            labelProvider: (point) => _defaultLabelProvider(point.y),
            lineColor: lineColor),
        rightAxisStyle: AxisStyle(
            textStyle: textStyle,
            labelInsets: EdgeInsets.only(left: fontSize / 2),
            labelProvider: (point) => _defaultLabelProvider(point.y),
            lineColor: lineColor));
  }

  DatasetStyle datasetStyleOfIndex(int index) {
    if (index < 0 || index >= datasetStyles.length) {
      throw 'Expecting style for $index';
    }
    return datasetStyles[index];
  }
}

typedef LabelFunction = String Function(DataPoint);

class AxisStyle {
  static final double defaultFontSize = _defaultFontSize;
  final int maxLabels;
  final LabelFunction labelProvider;
  final TextStyle textStyle;
  final bool drawLabels;
  final EdgeInsets labelInsets;
  final Color lineColor;
  final double lineSize;
  final double? absoluteMin;
  final double? absoluteMax;
  final double? valueMargin;

  AxisStyle(
      {required this.textStyle,
      required this.labelInsets,
      required this.labelProvider,
      required this.lineColor,
      this.lineSize = _defaultLineSize,
      this.drawLabels = true,
      this.maxLabels = 20,
      this.absoluteMin,
      this.absoluteMax,
      this.valueMargin});

  double get fontSize => textStyle.fontSize ?? defaultFontSize;
}

class LegendStyle {
  static final double defaultFontSize = _defaultFontSize;
  final Color lineColor;
  final TextStyle textStyle;
  final EdgeInsets insets;
  final borderSize = 1.0;

  LegendStyle(
      {required this.lineColor, required this.textStyle, required this.insets});

  double get fontSize => textStyle.fontSize ?? defaultFontSize;
  double get height => fontSize + insets.top + insets.bottom + (borderSize * 2);
}

class DatasetStyle {
  static const double defaultLineSize = _defaultLineSize;
  final Color color;
  final double lineSize;
  final double cubicIntensity;
  DatasetStyle(
      {required this.color,
      this.lineSize = defaultLineSize,
      this.cubicIntensity = 0.2});
}

List<Color> _defaultDatasetColors() =>
    [_Colors.primary, _Colors.secondary, _Colors.tertiary];

class _Colors {
  static final _opaque = 0xff;
  static final Color primary = Color.fromARGB(_opaque, 93, 165, 218);
  static final Color secondary = Color.fromARGB(_opaque, 250, 164, 58);
  static final Color tertiary = Color.fromARGB(_opaque, 170, 170, 170);
}

String _defaultLabelProvider(double v) => v.toStringAsFixed(1);

const _defaultLineSize = 1.0;
const _defaultFontSize = 12.0;
