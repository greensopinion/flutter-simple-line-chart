import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../simple_line_chart.dart';
import 'selection_model.dart';

class LineChartSelectionLabel extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  LineChartSelectionLabel(this.data, this.style);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(builder: (context, selectionModel, child) {
      final selectionStyle = style.selectionLabelStyle!;
      final children = <Widget>[];
      final xLabelProvider = selectionStyle.xAxisLabelProvider;
      if (xLabelProvider != null && selectionModel.selection.isNotEmpty) {
        final point = selectionModel.selection.first;
        children.add(Text(xLabelProvider(point.dataPoint),
            style: style.selectionLabelStyle!.textStyle));
      }
      children.addAll(labels(selectionStyle.leftYAxisLabelProvider,
          YAxisDependency.LEFT, selectionModel));
      children.addAll(labels(selectionStyle.rightYAxisLabelProvider,
          YAxisDependency.RIGHT, selectionModel));
      final background = Theme.of(context).canvasColor;
      return Container(
        decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: selectionStyle.borderColor,
                width: selectionStyle.borderSize)),
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)),
      );
    });
  }

  List<Widget> labels(LabelFunction? labelProvider, YAxisDependency dependency,
      SelectionModel selectionModel) {
    if (labelProvider == null) {
      return [];
    }
    return selectionModel.selection
        .where((d) => d.dataset.axisDependency == dependency)
        .map((d) => '${d.dataset.shortLabel}: ${labelProvider(d.dataPoint)}')
        .where((text) => text.isNotEmpty)
        .map((text) => Text(text, style: style.selectionLabelStyle!.textStyle))
        .toList();
  }
}
