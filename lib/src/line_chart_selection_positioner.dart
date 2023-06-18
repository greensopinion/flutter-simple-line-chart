import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_line_chart/simple_line_chart.dart';
import 'package:simple_line_chart/src/line_chart_selection_label.dart';
import 'package:simple_line_chart/src/selection_model.dart';

class LineChartSelectionPositioner extends StatelessWidget {
  final LineChartSelectionLabel child;
  LineChartSelectionPositioner({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionModel>(
        child: child,
        builder: (context, selectionModel, child) {
          if (selectionModel.selection.isNotEmpty) {
            final selectionOffset = _leftMostSelectionOffset(selectionModel);
            final minOffset = _leftMostPointOffset(selectionModel);
            final maxOffset = _rightMostPointOffset(selectionModel);
            final midPoint = (minOffset + maxOffset) / 2.0;
            if (selectionOffset < midPoint) {
              return Positioned(top: 8, right: 8, child: child!);
            }
          }
          return Positioned(top: 8, left: 8, child: child!);
        });
  }

  double _leftMostSelectionOffset(SelectionModel selectionModel) =>
      selectionModel.selection
          .map((point) => selectionModel.projection.toPixel(
              axisDependency: point.dataset.axisDependency,
              data: point.dataPoint.toOffset()))
          .map((offset) => offset.dx)
          .reduce(min);

  double _leftMostPointOffset(SelectionModel selectionModel) =>
      selectionModel.data.datasets
          .map((dataset) => selectionModel.projection.toPixel(
              axisDependency: dataset.axisDependency,
              data: dataset.dataPoints.first.toOffset()))
          .map((offset) => offset.dx)
          .reduce(min);
  double _rightMostPointOffset(SelectionModel selectionModel) =>
      selectionModel.data.datasets
          .map((dataset) => selectionModel.projection.toPixel(
              axisDependency: dataset.axisDependency,
              data: dataset.dataPoints.last.toOffset()))
          .map((offset) => offset.dx)
          .reduce(max);
}
