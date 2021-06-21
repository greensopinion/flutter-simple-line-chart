import 'package:flutter/painting.dart';

class LineChartData {
  final List<Dataset> datasets;

  LineChartData({required this.datasets});
}

class Dataset {
  final String label;
  final List<DataPoint> dataPoints;

  Dataset({required this.label, required this.dataPoints});
}

class DataPoint {
  final double x;
  final double y;
  final Object? model;

  DataPoint({required this.x, required this.y, this.model});
}
