import 'package:flutter/material.dart';
import 'package:simple_line_chart/src/style.dart';

import '../simple_line_chart.dart';
import 'legend.dart';

class LineChart extends StatelessWidget {
  final LineChartData data;
  final LineChartStyle style;

  const LineChart({Key? key, required this.style, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [Legend(style: style, data: data)]);
  }
}
