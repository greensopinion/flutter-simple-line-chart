import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class LineChartStyle {
  final LegendStyle legendStyle;
  final List<DatasetStyle> datasetStyles;

  LineChartStyle({required this.legendStyle, required this.datasetStyles});
  factory LineChartStyle.fromTheme(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText1 ?? theme.textTheme.bodyText2!;
    final lineColor = textStyle.color!;
    final datasetStyles = _defaultDatasetColors()
        .map((c) => DatasetStyle(color: c, textStyle: textStyle))
        .toList();
    final legendInsets =
        EdgeInsets.only(top: textStyle.fontSize ?? LegendStyle.defaultFontSize);
    return LineChartStyle(
        legendStyle: LegendStyle(lineColor: lineColor, insets: legendInsets),
        datasetStyles: datasetStyles);
  }

  DatasetStyle datasetStyleOfIndex(int index) {
    if (index < 0 || index >= datasetStyles.length) {
      throw 'Expecting style for $index';
    }
    return datasetStyles[index];
  }
}

class LegendStyle {
  static final double defaultFontSize = 12.0;
  final Color lineColor;
  final EdgeInsets insets;

  LegendStyle({required this.lineColor, required this.insets});
}

class DatasetStyle {
  final Color color;
  final TextStyle textStyle;
  DatasetStyle({required this.color, required this.textStyle});
}

List<Color> _defaultDatasetColors() =>
    [_Colors.primary, _Colors.secondary, _Colors.tertiary];

class _Colors {
  static final _opaque = 0xff;
  static final Color primary = Color.fromARGB(_opaque, 93, 165, 218);
  static final Color secondary = Color.fromARGB(_opaque, 250, 164, 58);
  static final Color tertiary = Color.fromARGB(_opaque, 170, 170, 170);
  static final Color highlight = Color.fromARGB(_opaque, 255, 87, 34);
}
