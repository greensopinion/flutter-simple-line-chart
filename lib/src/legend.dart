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
    final items = data.datasets.asMap().entries.map((e) => LegendItem(
        label: e.value.label, color: style.datasetStyleOfIndex(e.key).color));
    final legendStyle = style.legendStyle!;
    final boxSize =
        (legendStyle.textStyle.fontSize ?? LegendStyle.defaultFontSize);
    return Padding(
        padding: legendStyle.insets,
        child: Wrap(
            children: items
                .map((e) => Padding(
                    padding: EdgeInsets.only(right: boxSize),
                    child: _LegendItem(item: e, legendStyle: legendStyle)))
                .toList()));
  }
}

class LegendItem {
  final String label;
  final Color color;

  const LegendItem({required this.label, required this.color});
}

class _LegendItem extends StatelessWidget {
  final LegendItem item;
  final LegendStyle legendStyle;

  const _LegendItem({required this.item, required this.legendStyle});

  double get boxSize =>
      (legendStyle.textStyle.fontSize ?? LegendStyle.defaultFontSize);

  @override
  Widget build(BuildContext context) {
    final colorBox = SizedBox(
        width: boxSize,
        height: boxSize,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: legendStyle.borderColor,
                    width: legendStyle.borderSize),
                color: item.color)));
    final label = Text(item.label, style: legendStyle.textStyle);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      colorBox,
      Padding(padding: EdgeInsets.only(left: boxSize / 2.0), child: label)
    ]);
  }
}
