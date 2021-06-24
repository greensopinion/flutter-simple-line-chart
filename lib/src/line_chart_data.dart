import 'dart:math';
import 'dart:ui';

class LineChartData {
  final List<Dataset> datasets;

  LineChartData({required this.datasets});

  double get maxY => datasets.map((e) => e.maxY).reduce(max);
  double get minY => datasets.map((e) => e.minY).reduce(min);
  double get maxX => datasets.map((e) => e.maxX).reduce(max);
  double get minX => datasets.map((e) => e.minX).reduce(min);

  @override
  int get hashCode => datasets.hashCode;

  @override
  bool operator ==(Object other) =>
      other is LineChartData && other.datasets == datasets;
}

class Dataset {
  final String label;
  final List<DataPoint> dataPoints;

  Dataset({required this.label, required this.dataPoints});

  double get maxY => dataPoints.map((e) => e.y).reduce(max);
  double get minY => dataPoints.map((e) => e.y).reduce(min);
  double get maxX => dataPoints.map((e) => e.x).reduce(max);
  double get minX => dataPoints.map((e) => e.x).reduce(min);

  @override
  int get hashCode => hashValues(label, dataPoints);

  @override
  bool operator ==(Object other) =>
      other is Dataset &&
      other.label == label &&
      other.dataPoints == dataPoints;
}

class DataPoint {
  final double x;
  final double y;
  final Object? model;

  DataPoint({required this.x, required this.y, this.model});

  Offset toOffset() => Offset(x, y);

  @override
  int get hashCode => hashValues(x, y, model);

  @override
  bool operator ==(Object other) =>
      other is DataPoint &&
      other.x == x &&
      other.y == y &&
      other.model == model;
}
