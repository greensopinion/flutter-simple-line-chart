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
  final Duration? animationDuration;

  LineChartStyle(
      {required this.legendStyle,
      required this.datasetStyles,
      this.topAxisStyle,
      this.bottomAxisStyle,
      this.leftAxisStyle,
      this.rightAxisStyle,
      this.animationDuration = const Duration(seconds: 1)}) {
    assert(topAxisStyle != null || bottomAxisStyle != null);
    assert(leftAxisStyle != null || rightAxisStyle != null);
  }

  factory LineChartStyle.fromTheme(BuildContext context,
      {List<Color>? datasetColors}) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText1 ?? theme.textTheme.bodyText2!;
    final lineColor = textStyle.color!.withOpacity(0.3);
    final datasetStyles = (datasetColors ?? _defaultDatasetColors())
        .map((c) => DatasetStyle(color: c))
        .toList();
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

  LineChartStyle copyWith(
      {LegendStyle? legendStyle,
      List<DatasetStyle>? datasetStyles,
      AxisStyle? topAxisStyle,
      AxisStyle? bottomAxisStyle,
      AxisStyle? leftAxisStyle,
      AxisStyle? rightAxisStyle,
      Duration? animationDuration}) {
    return LineChartStyle(
        legendStyle: legendStyle ?? this.legendStyle,
        datasetStyles: datasetStyles ?? this.datasetStyles,
        animationDuration: animationDuration ?? this.animationDuration,
        bottomAxisStyle: bottomAxisStyle ?? this.bottomAxisStyle,
        leftAxisStyle: leftAxisStyle ?? this.leftAxisStyle,
        rightAxisStyle: rightAxisStyle ?? this.rightAxisStyle,
        topAxisStyle: topAxisStyle ?? this.topAxisStyle);
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

  AxisStyle copyWith(
      {int? maxLabels,
      LabelFunction? labelProvider,
      TextStyle? textStyle,
      bool? drawLabels,
      EdgeInsets? labelInsets,
      Color? lineColor,
      double? lineSize,
      double? absoluteMin,
      double? absoluteMax,
      double? valueMargin}) {
    return AxisStyle(
        textStyle: textStyle ?? this.textStyle,
        labelInsets: labelInsets ?? this.labelInsets,
        labelProvider: labelProvider ?? this.labelProvider,
        lineColor: lineColor ?? this.lineColor,
        lineSize: lineSize ?? this.lineSize,
        drawLabels: drawLabels ?? this.drawLabels,
        maxLabels: maxLabels ?? this.maxLabels,
        absoluteMin: absoluteMin ?? this.absoluteMin,
        absoluteMax: absoluteMax ?? this.absoluteMax,
        valueMargin: valueMargin ?? this.valueMargin);
  }
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

  LegendStyle copyWith(
      {Color? lineColor, TextStyle? textStyle, EdgeInsets? insets}) {
    return LegendStyle(
        lineColor: lineColor ?? this.lineColor,
        textStyle: textStyle ?? this.textStyle,
        insets: insets ?? this.insets);
  }
}

class DatasetStyle {
  static const double defaultLineSize = _defaultLineSize;
  final Color color;
  final double fillOpacity;
  final double lineSize;
  final double cubicIntensity;

  DatasetStyle(
      {required this.color,
      this.fillOpacity = 0.25,
      this.lineSize = defaultLineSize,
      this.cubicIntensity = 0.2});

  DatasetStyle copyWith(
      {Color? color,
      double? fillOpacity,
      double? lineSize,
      double? cubicIntensity}) {
    return DatasetStyle(
        color: color ?? this.color,
        fillOpacity: fillOpacity ?? this.fillOpacity,
        lineSize: lineSize ?? this.lineSize,
        cubicIntensity: cubicIntensity ?? this.cubicIntensity);
  }
}

List<Color> _defaultDatasetColors() =>
    [_Colors.primary, _Colors.secondary, _Colors.tertiary];

class _Colors {
  static final _opaque = 0xff;
  static final Color primary = Color.fromARGB(_opaque, 56, 142, 60);
  static final Color secondary = Color.fromARGB(_opaque, 25, 118, 210);
  static final Color tertiary = Color.fromARGB(_opaque, 194, 24, 91);
}

String _defaultLabelProvider(double v) => v.toStringAsFixed(1);

const _defaultLineSize = 1.0;
const _defaultFontSize = 12.0;
