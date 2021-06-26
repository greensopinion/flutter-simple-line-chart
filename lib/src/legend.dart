import 'package:flutter/material.dart';

import 'line_chart_data.dart';
import 'style.dart';

class Legend extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  const Legend({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: style.legendStyle!.insets,
        child: Wrap(
            children: data.datasets.asMap().entries.map((e) {
          final item = _LegendItem(
              style: style.datasetStyleOfIndex(e.key),
              legendStyle: style.legendStyle!,
              dataset: e.value);
          return Padding(
              padding: EdgeInsets.only(right: item.boxSize), child: item);
        }).toList()));
  }

  static double widthAroundText(LegendStyle style) {
    double boxSize = (style.textStyle.fontSize ?? LegendStyle.defaultFontSize);
    double borderSize = style.borderSize * 2;
    double padding = boxSize / 2;
    return boxSize + borderSize + padding;
  }
}

class _LegendItem extends StatelessWidget {
  final Dataset dataset;
  final DatasetStyle style;
  final LegendStyle legendStyle;

  double get boxSize =>
      (legendStyle.textStyle.fontSize ?? LegendStyle.defaultFontSize);

  const _LegendItem(
      {Key? key,
      required this.style,
      required this.legendStyle,
      required this.dataset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorBox = SizedBox(
        width: boxSize,
        height: boxSize,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: legendStyle.lineColor,
                    width: legendStyle.borderSize),
                color: style.color)));
    final label = Text(dataset.label, style: legendStyle.textStyle);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      colorBox,
      Padding(padding: EdgeInsets.only(left: boxSize / 2.0), child: label)
    ]);
  }
}
