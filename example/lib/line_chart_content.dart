import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_line_chart/simple_line_chart.dart';

class LineChartContent extends StatefulWidget {
  const LineChartContent({Key? key}) : super(key: key);

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

    // create a data model
    data = LineChartData(datasets: [
      Dataset(
          label: 'First', dataPoints: _createDataPoints(offsetInDegrees: 90)),
      Dataset(
          label: 'Second', dataPoints: _createDataPoints(offsetInDegrees: 0)),
      Dataset(
          label: 'Third', dataPoints: _createDataPoints(offsetInDegrees: 180))
    ], rangeDatasets: [
      RangeDataset(
          label: 'Fourth',
          axisDependency: XAxisDependency.TOP,
          gradientDistance: 3.0,
          bounds: Range(low: 0, high: _maxX.toDouble()),
          ranges: _createRanges()),
      RangeDataset(
          label: 'Fifth',
          axisDependency: XAxisDependency.BOTTOM,
          bounds: Range(low: 0, high: _maxX.toDouble()),
          ranges: _createRanges())
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final template = LineChartStyle.fromTheme(context);
    final style = template.copyWithAxes(
        topAxisStyle: template.topAxisStyle,
        leftAxisStyle: template.leftAxisStyle?.copyWith(
            labelIncrementMultiples: 100,
            marginAbove: 10,
            marginBelow: 10,
            applyMarginBelow: (minY) => minY < 0.0));
    return Column(children: [
      Padding(
          padding: const EdgeInsets.only(top: 20),
          child: LineChart(
              // chart is styled
              style: style,
              seriesHeight: 300,
              // chart has data
              data: data))
    ]);
  }
}

// data points are created on a sine curve here,
// but you can plot any data you like
List<DataPoint> _createDataPoints({required int offsetInDegrees}) {
  List<DataPoint> dataPoints = [];
  const degreesToRadians = (pi / 180);
  for (int x = 0; x < _maxX; x += 20) {
    final di = (x * 2).toDouble() * degreesToRadians;
    dataPoints.add(DataPoint(
        x: x.toDouble(),
        y: (100.0 * ((sin(di + offsetInDegrees) + 1.0) / 2.0))));
  }
  return dataPoints;
}

List<Range> _createRanges() {
  final ranges = <Range>[];
  final increment = (_maxX * 0.25).toInt();
  final size = (_maxX * 0.1).toInt();
  for (int x = (increment ~/ 2); x <= _maxX; x += increment) {
    ranges.add(Range(low: x.toDouble(), high: (x + size).toDouble()));
  }
  return ranges;
}

const _maxX = 180;
