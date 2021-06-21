import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

class LineChartContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LineChartContentState();
  }
}

class _LineChartContentState extends State<LineChartContent> {
  late final LineChartData data;

  @override
  void initState() {
    super.initState();

    data = LineChartData(datasets: [
      Dataset(
          label: 'First', dataPoints: _createDataPoints(offsetInDegrees: 90)),
      Dataset(
          label: 'Second', dataPoints: _createDataPoints(offsetInDegrees: 0)),
      Dataset(
          label: 'Third', dataPoints: _createDataPoints(offsetInDegrees: 180))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(style: LineChartStyle.fromTheme(context), data: data);
  }
}

List<DataPoint> _createDataPoints({required int offsetInDegrees}) {
  List<DataPoint> dataPoints = [];
  final degreesToRadians = (pi / 180);
  for (int x = 0; x < 180; ++x) {
    final di = (x * 2).toDouble() * degreesToRadians;
    dataPoints.add(DataPoint(
        x: x.toDouble(), y: 100.0 * ((sin(di + offsetInDegrees) + 1.0) / 2.0)));
  }
  return dataPoints;
}
